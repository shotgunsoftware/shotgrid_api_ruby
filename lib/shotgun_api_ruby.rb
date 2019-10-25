# frozen_string_literal: true

# zeitwerk will take care of auto loading files based on their name :)
require "zeitwerk"
require "faraday"
require 'json'

loader = Zeitwerk::Loader.for_gem
loader.setup # ready!

module ShotgunApiRuby
  def self.new(**args)
    Client.new(**args)
  end
end
