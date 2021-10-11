# typed: strict
# frozen_string_literal: true

module ShotgridApiRuby
  # Main class for connection.
  #
  # This should be only instanciated once to re-use tokens
  class Client
    extend T::Sig

    sig do
      params(
        auth: Types::AuthType,
        site_url: T.nilable(String),
        shotgun_site: T.nilable(String),
        shotgrid_site: T.nilable(String),
      ).void
    end
    def initialize(auth:, site_url: nil, shotgun_site: nil, shotgrid_site: nil)
      raise 'No site given' unless site_url || shotgun_site || shotgrid_site
      if !Auth::Validator.valid?(
           client_id: auth[:client_id],
           client_secret: auth[:client_secret],
           username: auth[:username],
           password: auth[:password],
           session_token: auth[:session_token],
           refresh_token: auth[:refresh_token],
         )
        raise 'auth param not valid'
      end

      site_url ||=
        if shotgun_site
          "https://#{shotgun_site}.shotgunstudio.com/api/v1"
        elsif shotgrid_site
          "https://#{shotgrid_site}.shotgrid.autodesk.com/api/v1"
        end

      @connection =
        T.let(
          Faraday.new(url: site_url) do |faraday|
            faraday.use(ShotgridApiRuby::Auth, auth: auth, site_url: site_url)
            faraday.adapter Faraday.default_adapter
          end,
          Faraday::Connection,
        )
      @preferences = T.let(nil, T.nilable(Preferences))
      @server_info = T.let(nil, T.nilable(ServerInfo))
      @entity_caller = T.let(nil, T.nilable(Entities))
    end

    # Faraday connection
    sig { returns(Faraday::Connection) }
    attr_reader :connection

    # Access preferences APIs
    sig { returns(Preferences) }
    def preferences
      @preferences = Preferences.new(connection)
    end

    # Access server_info APIs
    sig { returns(ServerInfo) }
    def server_info
      @server_info || ServerInfo.new(connection)
    end

    # Access entities related APIs
    sig { params(type: T.any(Symbol, String)).returns(Entities) }
    def entities(type)
      public_send(type)
    end

    sig do
      params(_name: T.untyped, _include_private: T.untyped).returns(TrueClass)
    end
    def respond_to_missing?(_name, _include_private = false)
      true
    end

    sig do
      params(
          name: T.any(String, Symbol),
          args: T::Array[T.untyped],
          block: T.nilable(Proc),
        )
        .returns(Entities)
    end
    def method_missing(name, *args, &block)
      if args.empty?
        fname = formated_name(name)
        self
          .class
          .define_method(fname) do
            if entities_client = instance_variable_get("@#{fname}")
              entities_client
            else
              entities_client = entities_aux(fname)
              instance_variable_set("@#{fname}", entities_client)
            end
          end
        self.class.instance_eval { alias_method name, fname }
        send(fname)
      else
        super
      end
    end

    private

    sig { params(name: T.any(String, Symbol)).returns(String) }
    def formated_name(name)
      name.to_s.camelize.singularize
    end

    sig { params(type: T.any(String, Symbol)).returns(Entities) }
    def entities_aux(type)
      type = formated_name(type)
      @entity_caller = Entities.new(connection, type)
    end
  end
end
