# frozen_string_literal: true

module ShotgridApiRuby
  class Entities
    def initialize(connection, type)
      @connection = connection.dup
      @type = type
      @base_url_prefix = @connection.url_prefix
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
        page_size: 1,
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

      entity = resp_body['data']
      Entity.new(
        entity['type'],
        OpenStruct.new(entity['attributes']),
        entity['relationships'],
        entity['id'],
        entity['links'],
      )
    end

    def create(attributes)
      resp =
        @connection.post('', attributes.to_json) do |req|
          req.headers['Content-Type'] = 'application/json'
        end

      resp_body = JSON.parse(resp.body)

      if resp.status >= 300
        raise "Error while creating #{type} with #{attributes}: #{
                resp_body['errors']
              }"
      end

      entity = resp_body['data']
      Entity.new(
        entity['type'],
        OpenStruct.new(entity['attributes']),
        entity['relationships'],
        entity['id'],
        entity['links'],
      )
    end

    def update(id, changes)
      return find(id) if changes.empty?

      resp =
        @connection.put(id.to_s, changes.to_json) do |req|
          req.headers['Content-Type'] = 'application/json'
        end

      resp_body = JSON.parse(resp.body)

      if resp.status >= 300
        raise "Error while updating #{type}##{id} with #{changes}: #{
                resp_body['errors']
              }"
      end

      entity = resp_body['data']
      Entity.new(
        entity['type'],
        OpenStruct.new(entity['attributes']),
        entity['relationships'],
        entity['id'],
        entity['links'],
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
      resp = @connection.post("#{id}?revive=true")

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
      if filter && !Params.filters_are_simple?(filter)
        return(
          search(
            fields: fields,
            logical_operator: logical_operator,
            sort: sort,
            filter: filter,
            page: page,
            page_size: page_size,
            retired: retired,
            include_archived_projects: include_archived_projects,
          )
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

      resp_body['data'].map do |entity|
        Entity.new(
          entity['type'],
          OpenStruct.new(entity['attributes']),
          entity['relationships'],
          entity['id'],
          entity['links'],
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
      if filter.nil? || Params.filters_are_simple?(filter)
        return(
          all(
            fields: fields,
            logical_operator: logical_operator,
            sort: sort,
            filter: filter,
            page: page,
            page_size: page_size,
            retired: retired,
            include_archived_projects: include_archived_projects,
          )
        )
      end
      params = Params.new

      params.add_fields(fields)
      params.add_sort(sort)
      params.add_page(page, page_size)
      params.add_options(retired, include_archived_projects)
      params.add_filter(filter, logical_operator)

      # In search: The name is filters and not filter
      params[:filters] = params[:filter] if params[:filter]
      params.delete(:filter)

      resp =
        @connection.post('_search', params) do |req|
          req.headers['Content-Type'] =
            if params[:filters].is_a? Array
              'application/vnd+shotgun.api3_array+json'
            else
              'application/vnd+shotgun.api3_hash+json'
            end
          req.body = params.to_h.to_json
        end
      resp_body = JSON.parse(resp.body)

      if resp.status >= 300
        raise "Error while getting #{type}: #{resp_body['errors']}"
      end

      resp_body['data'].map do |entity|
        Entity.new(
          entity['type'],
          OpenStruct.new(entity['attributes']),
          entity['relationships'],
          entity['id'],
          entity['links'],
        )
      end
    end

    def schema_client
      @schema_client ||= Schema.new(connection, type, @base_url_prefix)
    end

    def schema
      schema_client.read
    end

    def fields
      schema_client.fields
    end

    def summary_client
      @summary_client ||= Summarize.new(connection, type, @base_url_prefix)
    end

    def count(filter: nil, logical_operator: 'and')
      summary_client.count(filter: filter, logical_operator: logical_operator)
    end

    def summarize(
      filter: nil,
      grouping: nil,
      summary_fields: nil,
      logical_operator: 'and',
      include_archived_projects: nil
    )
      summary_client.summarize(
        filter: filter,
        grouping: grouping,
        summary_fields: summary_fields,
        logical_operator: logical_operator,
        include_archived_projects: include_archived_projects,
      )
    end
  end
end
