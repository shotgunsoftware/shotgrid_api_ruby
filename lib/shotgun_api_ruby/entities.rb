# frozen_string_literal: true

module ShotgunApiRuby
  class Entities
    def initialize(connection, type)
      @connection = connection.dup
      @type = type
      @connection.url_prefix = "#{@connection.url_prefix}/entity/#{type}"
    end

    attr_reader :connection, :type

    def all(fields: nil, sort: nil, filter: nil)
      raise "Complex filters aren't supported yet" if filter && !filters_are_simple?(filter)

      params = Params.new

      params.add_fields(fields)
      params.add_sort(sort)
      params.add_filter(filter)

      p params.to_h

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

    private

    def filters_are_simple?(filters)
      filters.values.all? do |filter_val|
        (filter_val.is_a?(String) || filter_val.is_a?(Symbol)) ||
          (filter_val.is_a?(Array) && filter_val.all?{ |val| val.is_a?(String) || val.is_a?(Symbol) })
      end
    end

    class Params < Hash
      def add_sort(sort)
        return unless sort

        self[:sort] =
          if sort.is_a?(Hash)
            sort.map{ |field, direction| "#{direction.to_s.start_with?('desc') ? '-' : ''}#{field}" }.join(',')
          else
            [sort].flatten.join(',')
          end
      end

      def add_fields(fields)
        self[:fields] = [fields].flatten.join(',') if fields
      end

      def add_filter(filters)
        return unless filters

        # filter
        self['filter'] = filters.map do |field, value|
          [
            field.to_s,
            value.is_a?(Array) ? value.map(&:to_s).join(',') : value.to_s,
          ]
        end.to_h
      end
    end
  end
end
