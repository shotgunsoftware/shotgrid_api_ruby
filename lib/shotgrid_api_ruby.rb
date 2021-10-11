# typed: strict
# frozen_string_literal: true

# zeitwerk will take care of auto loading files based on their name :)
require 'zeitwerk'
require 'active_support/core_ext/string/inflections'
require 'ostruct'
require 'faraday'
require 'sorbet-runtime'
require 'json'

loader = Zeitwerk::Loader.for_gem
loader.setup # ready!

module ShotgridApiRuby
  extend T::Sig

  sig do
    params(
        auth: ShotgridApiRuby::Types::AuthType,
        site_url: T.nilable(String),
        shotgun_site: T.nilable(String),
        shotgrid_site: T.nilable(String),
      )
      .returns(Client)
  end
  def self.new(auth:, site_url: nil, shotgun_site: nil, shotgrid_site: nil)
    Client.new(
      auth: auth,
      site_url: site_url,
      shotgun_site: shotgun_site,
      shotgrid_site: shotgrid_site,
    )
  end
end

loader.eager_load
