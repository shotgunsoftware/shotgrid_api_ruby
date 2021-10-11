# typed: strict
# frozen_string_literal: true

module ShotgridApiRuby
  class Preferences
    extend T::Sig

    sig { params(connection: Faraday::Connection).void }
    def initialize(connection)
      @connection = T.let(connection.dup, Faraday::Connection)
      @connection.url_prefix = "#{@connection.url_prefix}/preferences"
    end

    sig { returns(Faraday::Connection) }
    attr_reader :connection

    sig { returns(OpenStruct) }
    def all
      resp = @connection.get
      resp_body = JSON.parse(resp.body)

      if resp.status >= 300
        raise ShotgridCallError.new(
                response: resp,
                message:
                  "Error while getting server preferences: #{resp_body['errors']}",
              )
      end

      data = resp_body['data']
      OpenStruct.new(data)
    end
  end
end
