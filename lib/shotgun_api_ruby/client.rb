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

    def entity
      @entity_caller = Entity.new(connection)
    end
  end
end
