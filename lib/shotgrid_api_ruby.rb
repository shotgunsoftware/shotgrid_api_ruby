# typed: true
# frozen_string_literal: true

# zeitwerk will take care of auto loading files based on their name :)
require 'zeitwerk'
require 'active_support/core_ext/string/inflections'
require 'ostruct'
require 'faraday'
require 'json'

loader = Zeitwerk::Loader.for_gem
loader.setup # ready!

module ShotgridApiRuby
  def self.new(**args)
    Client.new(
      auth: args[:auth],
      site_url: args[:site_url],
      shotgun_site: args[:shotgun_site],
      shotgrid_site: args[:shotgrid_site],
    )
  end
end

loader.eager_load
