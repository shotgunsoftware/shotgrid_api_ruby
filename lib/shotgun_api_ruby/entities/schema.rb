# frozen_string_literal: true

module ShotgunApiRuby
  class Entities
    class Schema
      def initialize(connection, type, base_url_prefix)
        @connection = connection.dup
        @type = type
        @connection.url_prefix = "#{base_url_prefix}/schema/#{type}"
      end
      attr_reader :type, :connection

      def read
        resp = @connection.get('')

        if resp.status >= 300
          raise "Error while read schema for #{type}: #{resp.body}"
        end

        resp_body = JSON.parse(resp.body)

        OpenStruct.new(
          resp_body["data"].transform_values{ |v| v["value"] }
        )
      end

      def fields
        resp = @connection.get('fields')
        resp_body = JSON.parse(resp.body)

        if resp.status >= 300
          raise "Error while read schema fields for #{type}: #{resp.body}"
        end

        OpenStruct.new(
          resp_body["data"].transform_values do |value|
            OpenStruct.new(
              value.transform_values do |attribute|
                attribute["value"]
              end.merge(
                properties: OpenStruct.new(value["properties"].transform_values{ |prop| prop["value"] })
              )
            )
          end
        )
      end
    end
  end
end
