# frozen_string_literal: true

module ShotgunApiRuby
  class Client
    attr_reader :connection

    def initialize(auth:, site_url: nil, shotgun_site: nil)
      raise "No site given" unless site_url || shotgun_site
      raise "auth param not valid" unless auth && Auth::Validator.valid?(auth)

      site_url ||= "https://#{shotgun_site}.shotgunstudio.com/api/v1"
      @connection =
        Faraday.new(url: site_url) do |faraday|
          faraday.use(ShotgunApiRuby::Auth, auth: auth, site_url: site_url)
          faraday.adapter Faraday.default_adapter
        end
    end

    def preferences
      @preferences = Preferences.new(connection)
    end

    def server_info
      @server_info || ServerInfo.new(connection)
    end

    def entities(type)
      public_send(type)
    end

    def respond_to_missing?(_name, _include_private = false) # rubocop:disable Lint/MissingSuper,Style/OptionalBooleanParameter
      true
    end

    def method_missing(name, *args, &block)
      if args.empty?
        name = formated_name(name)
        define_singleton_method(name) do
          if entities_client = instance_variable_get("@#{name}")
            entities_client
          else
            entities_client = entities_aux(name)
            instance_variable_set("@#{name}", entities_client)
          end
        end
        send(name)
      else
        super
      end
    end

    private

    def formated_name(name)
      name.to_s.camelize.singularize
    end

    def entities_aux(type)
      type = formated_name(type)
      @entity_caller = Entities.new(connection, type)
    end
  end
end
