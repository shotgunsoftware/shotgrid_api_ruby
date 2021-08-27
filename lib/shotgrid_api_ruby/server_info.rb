# typed: false
# frozen_string_literal: true

module ShotgridApiRuby
  class ServerInfo
    def initialize(connection)
      @connection = connection
    end

    attr_reader :connection

    def get
      resp = @connection.get
      resp_body = JSON.parse(resp.body)

      if resp.status >= 300
        raise ShotgridCallError.new(
                response: resp,
                message:
                  "Error while getting server infos: #{resp_body['errors']}",
              )
      end

      data = resp_body['data']
      OpenStruct.new(data)
    end
  end
end
