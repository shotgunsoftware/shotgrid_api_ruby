# frozen_string_literal: true

# zeitwerk will take care of auto loading files based on their name :)
require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup # ready!

module ShotgunApiRuby
end
