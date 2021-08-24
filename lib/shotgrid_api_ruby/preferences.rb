# frozen_string_literal: true

module ShotgridApiRuby
  class Preferences
    def initialize(connection)
      @connection = connection.dup
      @connection.url_prefix = "#{@connection.url_prefix}/preferences"
    end

    attr_reader :connection

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
