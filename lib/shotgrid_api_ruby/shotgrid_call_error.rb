# typed: strict
require 'forwardable'

module ShotgridApiRuby
  class ShotgridCallError < StandardError
    extend T::Sig
    extend Forwardable

    sig { params(response: T.untyped, message: String).void }
    def initialize(response:, message:)
      @response = T.let(response, T.untyped)
      super(message)
    end

    sig { returns(T.untyped) }
    attr_reader :response
    def_delegators :response, :status
  end
end
