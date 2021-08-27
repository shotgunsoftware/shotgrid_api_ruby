# typed: true
# frozen_string_literal: true

module ShotgridApiRuby
  # Main class for connection.
  #
  # This should be only instanciated once to re-use tokens
  class Client
    # Faraday connection
    attr_reader :connection

    def initialize(auth:, site_url: nil, shotgun_site: nil, shotgrid_site: nil)
      raise 'No site given' unless site_url || shotgun_site || shotgrid_site
      raise 'auth param not valid' unless auth && Auth::Validator.valid?(**auth)

      site_url ||=
        if shotgun_site
          "https://#{shotgun_site}.shotgunstudio.com/api/v1"
        elsif shotgrid_site
          "https://#{shotgrid_site}.shotgrid.autodesk.com/api/v1"
        end

      @connection =
        Faraday.new(url: site_url) do |faraday|
          faraday.use(ShotgridApiRuby::Auth, auth: auth, site_url: site_url)
          faraday.adapter Faraday.default_adapter
        end
    end

    # Access preferences APIs
    def preferences
      @preferences = Preferences.new(connection)
    end

    # Access server_info APIs
    def server_info
      @server_info || ServerInfo.new(connection)
    end

    # Access entities related APIs
    def entities(type)
      public_send(type)
    end

    def respond_to_missing?(_name, _include_private = false)
      true
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

    def formated_name(name)
      name.to_s.camelize.singularize
    end

    def entities_aux(type)
      type = formated_name(type)
      @entity_caller = Entities.new(connection, type)
    end
  end
end
