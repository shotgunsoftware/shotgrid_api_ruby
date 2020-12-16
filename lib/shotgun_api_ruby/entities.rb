# frozen_string_literal: true

module ShotgunApiRuby
  class Entities
    def initialize(connection, type)
      @connection = connection.dup
      @type = type
      @connection.url_prefix = "#{@connection.url_prefix}/entity/#{type}"
    end

    attr_reader :connection, :type

    def first(
      fields: nil,
      sort: nil,
      filter: nil,
      retired: nil,
      include_archived_projects: nil,
      logical_operator: 'and'
    )
      all(
        fields: fields,
        sort: sort,
        filter: filter,
        retired: retired,
        logical_operator: logical_operator,
        include_archived_projects: include_archived_projects,
        page_size: 1
      ).first
    end

    def find(id, fields: nil, retired: nil, include_archived_projects: nil)
      params = Params.new

      params.add_fields(fields)
      params.add_options(retired, include_archived_projects)

      resp = @connection.get(id.to_s, params)
      resp_body = JSON.parse(resp.body)

      if resp.status >= 300
        raise "Error while getting #{type}: #{resp_body['errors']}"
      end

      entity = resp_body["data"]
      Entity.new(
        entity['type'],
        OpenStruct.new(entity['attributes']),
        entity['relationships'],
        entity['id'],
        entity['links']
      )
    end

    def create(**attributes)
      resp =
        @connection.post('', attributes.to_json) do |req|
          req.headers['Content-Type'] = 'application/json'
        end

      resp_body = JSON.parse(resp.body)

      if resp.status >= 300
        raise "Error while creating #{type}# with #{attributes}: #{resp_body['errors']}"
      end

      entity = resp_body["data"]
      Entity.new(
        entity['type'],
        OpenStruct.new(entity['attributes']),
        entity['relationships'],
        entity['id'],
        entity['links']
      )
    end

    def update(id, **changes)
      return find(id) if changes.empty?

      resp =
        @connection.put(id.to_s, changes.to_json) do |req|
          req.headers['Content-Type'] = 'application/json'
        end

      resp_body = JSON.parse(resp.body)

      if resp.status >= 300
        raise "Error while updating #{type}##{id} with #{changes}: #{resp_body['errors']}"
      end

      entity = resp_body["data"]
      Entity.new(
        entity['type'],
        OpenStruct.new(entity['attributes']),
        entity['relationships'],
        entity['id'],
        entity['links']
      )
    end

    def delete(id)
      resp =
        @connection.delete(id.to_s) do |req|
          req.headers['Content-Type'] = 'application/json'
        end

      if resp.status >= 300
        resp_body = JSON.parse(resp.body)
        raise "Error while deleting #{type}##{id}: #{resp_body['errors']}"
      end

      true
    end

    def revive(id)
      resp =
        @connection.post("#{id}?revive=true")

      if resp.status >= 300
        resp_body = JSON.parse(resp.body)
        raise "Error while reviving #{type}##{id}: #{resp_body['errors']}"
      end

      true
    end

    def all(
      fields: nil,
      logical_operator: 'and',
      sort: nil,
      filter: nil,
      page: nil,
      page_size: nil,
      retired: nil,
      include_archived_projects: nil
    )
      if filter && !filters_are_simple?(filter)
        return search(
          fields: fields,
          logical_operator: logical_operator,
          sort: sort,
          filter: filter,
          page: page,
          page_size: page_size,
          retired: retired,
          include_archived_projects: include_archived_projects
        )
      end

      params = Params.new

      params.add_fields(fields)
      params.add_sort(sort)
      params.add_filter(filter)
      params.add_page(page, page_size)
      params.add_options(retired, include_archived_projects)

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

    def search(
      fields: nil,
      logical_operator: 'and',
      sort: nil,
      filter: nil,
      page: nil,
      page_size: nil,
      retired: nil,
      include_archived_projects: nil
    )
      if filter.nil? || filters_are_simple?(filter)
        return all(
          fields: fields,
          logical_operator: logical_operator,
          sort: sort,
          filter: filter,
          page: page,
          page_size: page_size,
          retired: retired,
          include_archived_projects: include_archived_projects
        )
      end
      params = Params.new

      params.add_fields(fields)
      params.add_sort(sort)
      params.add_page(page, page_size)
      params.add_options(retired, include_archived_projects)
      new_filter = {}
      if filter.is_a?(Hash)
        new_filter[:conditions] =
          (filter[:conditions] || translate_complex_to_sg_filters(filter))
        new_filter[:logical_operator] = filter[:logical_operator] || filter['logical_operator'] || logical_operator
      else
        new_filter[:conditions] = filter
        new_filter[:logical_operator] = logical_operator
      end
      filter = new_filter

      resp =
        @connection.post('_search', params) do |req|
          if filter.is_a? Array
            req.headers["Content-Type"] = 'application/vnd+shotgun.api3_array+json'
          else
            req.headers['Content-Type'] = 'application/vnd+shotgun.api3_hash+json'
          end
          req.body = params.to_h.merge(filters: filter).to_json
          pp JSON.parse(req.body)
        end
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
      return false if filters.is_a? Array

      filters.values.all? do |filter_val|
        (filter_val.is_a?(Integer) || filter_val.is_a?(String) || filter_val.is_a?(Symbol)) ||
          (filter_val.is_a?(Array) && filter_val.all?{ |val|
             val.is_a?(String) || val.is_a?(Symbol) || val.is_a?(Integer)
           } )
      end
    end

    def translate_complex_to_sg_filters(filters)
      # We don't know how to translate anything but hashes
      return filters if !filters.is_a?(Hash)

      filters.each.with_object([]) do |item, result|
        field, value = item
        case value
        when String, Symbol, Integer, Float
          result << [field, "is", value]
        when Hash
          value.each do |subfield, subvalue|
            sanitized_subfield = "#{field.capitalize}.#{subfield}" unless subfield.to_s.include?(".")
            case subvalue
            when String, Symbol, Integer, Float
              result << ["#{field}.#{sanitized_subfield}", "is", subvalue]
            when Array
              result << ["#{field}.#{sanitized_subfield}", "in", subvalue]
            else
              raise "This case is too complex to auto-translate. Please use shotgun query syntax."
            end
          end
        when Array
          result << [field, "in", value]
        else
          raise "This case is too complex to auto-translate. Please use shotgun query syntax."
        end
      end
    end
  end
end
