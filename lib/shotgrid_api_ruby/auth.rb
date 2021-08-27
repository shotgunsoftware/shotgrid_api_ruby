# typed: strict
# frozen_string_literal: true

module ShotgridApiRuby
  # Faraday middleware responsible for authentication with
  # the shotgrid site
  class Auth < Faraday::Middleware
    extend T::Sig

    # Validate auth parameters format
    module Validator
      extend T::Sig

      # Validate auth parameters format
      sig do
        params(
            client_id: T.nilable(String),
            client_secret: T.nilable(String),
            username: T.nilable(String),
            password: T.nilable(String),
            session_token: T.nilable(String),
            refresh_token: T.nilable(String),
          )
          .returns(T::Boolean)
      end
      def self.valid?(
        client_id: nil,
        client_secret: nil,
        username: nil,
        password: nil,
        session_token: nil,
        refresh_token: nil
      )
        !!(
          (client_id && client_secret) || (password && username) ||
            session_token || refresh_token
        )
      end
    end

    sig do
      params(
        app: T.untyped,
        options: {
          site_url: T.nilable(String),
          auth: T.nilable(Types::AuthType),
        },
      ).void
    end
    def initialize(app = nil, options = { auth: nil, site_url: nil })
      raise 'missing auth' unless options[:auth]
      raise 'missing site_url' unless options[:site_url]
      unless Validator.valid?(**options[:auth]&.transform_keys(&:to_sym))
        raise 'Auth not valid'
      end

      @site_url = T.let(options[:site_url], String)
      @client_id = T.let(options[:auth][:client_id], T.nilable(String))
      @client_secret = T.let(options[:auth][:client_secret], T.nilable(String))
      @username = T.let(options[:auth][:username], T.nilable(String))
      @password = T.let(options[:auth][:password], T.nilable(String))
      @session_token = T.let(options[:auth][:session_token], T.nilable(String))
      @refresh_token = T.let(options[:auth][:refresh_token], T.nilable(String))
      @app =
        T.let(
          nil,
          T.nilable(T.any(Faraday::Middleware, VCR::Middleware::Faraday)),
        )
      @auth_type = T.let(nil, T.nilable(String))
      @auth_params = T.let(nil, T.nilable(String))
      @auth_url = T.let(nil, T.nilable(String))
      @access_token = T.let(nil, T.nilable(String))
      @token_expiry = T.let(nil, T.nilable(Time))

      super(app)
    end

    sig { returns(T.nilable(String)) }
    attr_reader :client_id

    sig { returns(T.nilable(String)) }
    attr_reader :client_secret

    sig { returns(String) }
    attr_reader :site_url

    sig { returns(T.nilable(String)) }
    attr_reader :username

    sig { returns(T.nilable(String)) }
    attr_reader :password

    sig { returns(T.nilable(String)) }
    attr_reader :session_token

    sig { returns(T.nilable(String)) }
    attr_reader :refresh_token

    sig { returns(String) }
    def auth_type
      @auth_type ||=
        if refresh_token
          'refresh_token'
        elsif client_id
          'client_credentials'
        elsif username
          'password'
        elsif session_token
          'session_token'
        else
          ''
        end
    end

    sig { params(request_env: Faraday::Env).returns(Faraday::Response) }
    def call(request_env)
      request_env[:request_headers].merge!(std_headers)

      @app&.call(request_env)
    end

    private

    sig { returns(String) }
    def auth_params
      @auth_params ||=
        begin
          case auth_type
          when 'refresh_token'
            "refresh_token=#{refresh_token}&grant_type=refresh_token"
          when 'client_credentials'
            "client_id=#{client_id}&client_secret=#{
              client_secret
            }&grant_type=client_credentials"
          when 'password'
            "username=#{username}&password=#{password}&grant_type=password"
          when 'session_token'
            "session_token=#{session_token}&grant_type=session_token"
          else
            raise 'Not a valid/implemented auth type'
          end
        end
    end

    sig { returns(String) }
    def auth_url
      @auth_url ||= "#{site_url}/auth/access_token?#{auth_params}"
    end

    sig { returns(String) }
    def access_token
      sign_in if (!@access_token || Time.now > (@token_expiry || Time.now))
      @access_token || ''
    end

    sig { returns(String) }
    def sign_in
      resp =
        Faraday.post(auth_url) do |req|
          req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
          req.headers['Accept'] = 'application/json'
        end
      resp_body = JSON.parse(resp.body)

      if resp.status >= 300
        raise ShotgridCallError.new(
                response: resp,
                message: "Can't login: #{resp_body['errors']}",
              )
      end

      @token_expiry = Time.now + resp_body['expires_in']
      @refresh_token = resp_body['refresh_token']
      @access_token = resp_body['access_token']
    end

    sig { returns(T::Hash[String, String]) }
    def std_headers
      {
        'Accept' => 'application/json',
        'Authorization' => "Bearer #{access_token}",
      }
    end
  end
end
