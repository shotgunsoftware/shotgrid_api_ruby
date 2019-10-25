# frozen_string_literal: true

module ShotgunApiRuby
  class Entities
    Entity =
      Struct.new(:type, :attributes, :relationships, :id, :links) do
        def method_missing(name, *args, &block)
          if attributes.respond_to?(name)
            define_singleton_method(name) do
              attributes.public_send(name)
            end
            public_send(name)
          else
            super
          end
        end

        def respond_to_missing?(name, _private_methods = false)
          attributes.respond_to?(name) || super
        end
      end

    def initialize(connection, type)
      @connection = connection.dup
      @type = type
      @connection.url_prefix = "#{@connection.url_prefix}/entity/#{type}"
    end

    attr_reader :connection, :type

    def all(fields: nil, sort: nil)
      params = {}

      params[:fields] = [fields].flatten.join(',') if fields

      if sort
        params[:sort] =
          if sort.is_a?(Hash)
            sort.map{ |field, direction| "#{direction.to_s.start_with?('desc') ? '-' : ''}#{field}" }.join(',')
          else
            [sort].flatten.join(',')
          end
      end

      resp = @connection.get('', params)
      resp_body = JSON.parse(resp.body)

      if resp.status >= 300
        raise "Error while getting #{type}: #{resp_body['errors']}"
      end

      resp_body["data"].map do |entity|
        Entity.new(
          entity['type'],
          OpenStruct.new(entity['attributes']),
          entity['relationships'],
          entity['id'],
          entity['links']
        )
      end
    end
  end
end
