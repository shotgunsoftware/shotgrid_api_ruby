require 'forwardable'

module ShotgridApiRuby
  class ShotgridCallError < StandardError
    extend Forwardable

    def initialize(response:, message:)
      @response = response
      super(message)
    end

    attr_reader :response
    def_delegators :response, :status
  end
end
