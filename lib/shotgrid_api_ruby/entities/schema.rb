# typed: strict
# frozen_string_literal: true

module ShotgridApiRuby
  class Entities
    class Schema
      extend T::Sig

      sig do
        params(
          connection: Faraday::Connection,
          type: T.any(String, Symbol),
          base_url_prefix: URI,
        ).void
      end
      def initialize(connection, type, base_url_prefix)
        @connection = T.let(connection.dup, Faraday::Connection)
        @type = T.let(type, T.any(String, Symbol))
        @connection.url_prefix = "#{base_url_prefix}/schema/#{type}"
      end
      sig { returns(T.any(String, Symbol)) }
      attr_reader :type
      sig { returns(Faraday::Connection) }
      attr_reader :connection

      sig { returns(OpenStruct) }
      def read
        resp = @connection.get('')

        if resp.status >= 300
          raise ShotgridCallError.new(
                  response: resp,
                  message: "Error while read schema for #{type}: #{resp.body}",
                )
        end

        resp_body = JSON.parse(resp.body)

        OpenStruct.new(resp_body['data'].transform_values { |v| v['value'] })
      end

      sig { returns(OpenStruct) }
      def fields
        resp = @connection.get('fields')
        resp_body = JSON.parse(resp.body)

        if resp.status >= 300
          raise ShotgridCallError.new(
                  response: resp,
                  message:
                    "Error while read schema fields for #{type}: #{resp.body}",
                )
        end

        OpenStruct.new(
          resp_body['data'].transform_values do |value|
            OpenStruct.new(
              value
                .transform_values { |attribute| attribute['value'] }
                .merge(
                  properties:
                    OpenStruct.new(
                      value['properties'].transform_values do |prop|
                        prop['value']
                      end,
                    ),
                ),
            )
          end,
        )
      end
    end
  end
end
