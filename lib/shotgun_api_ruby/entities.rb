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
      include_archived_projects: nil
    )
      all(
        fields: fields,
        sort: sort,
        filter: filter,
        retired: retired,
        include_archived_projects: include_archived_projects,
        page_size: 1
      )
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

    def all(
      fields: nil,
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

      resp =
        @connection.post('_search', params) do |req|
          if filter.is_a? Array
            req.headers["Content-Type"] = 'application/vnd+shotgun.api3_array+json'
          else
            req.headers['Content-Type'] = 'application/vnd+shotgun.api3_hash+json'
          end
          req.body = params.to_h.merge(filters: filter).to_json
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
        (filter_val.is_a?(String) || filter_val.is_a?(Symbol)) ||
          (filter_val.is_a?(Array) && filter_val.all?{ |val| val.is_a?(String) || val.is_a?(Symbol) })
      end
    end
  end
end
