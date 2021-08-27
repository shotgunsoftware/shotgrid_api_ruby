# typed: strict
# frozen_string_literal: true

module ShotgridApiRuby
  class Entities
    extend T::Sig

    sig do
      params(connection: Faraday::Connection, type: T.any(String, Symbol)).void
    end
    def initialize(connection, type)
      @connection = T.let(connection.dup, Faraday::Connection)
      @type = T.let(type.to_s, String)
      @base_url_prefix = T.let(@connection.url_prefix, URI)
      @connection.url_prefix = "#{@connection.url_prefix}/entity/#{type}"
      @schema_client = T.let(nil, T.nilable(Schema))
      @summary_client = T.let(nil, T.nilable(Summarize))
    end

    sig { returns(Faraday::Connection) }
    attr_reader :connection

    sig { returns(String) }
    attr_reader :type

    sig do
      params(
          fields: Params::FIELDS_TYPE,
          sort: Params::SORT_TYPE,
          filter: Params::FILTERS_FIELD_TYPE,
          retired: T.nilable(T::Boolean),
          include_archived_projects: T.nilable(T::Boolean),
          logical_operator: Params::LOGICAL_OPERATOR_TYPE,
        )
        .returns(T.nilable(Entity))
    end
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

    sig do
      params(
          id: Integer,
          fields: Params::FIELDS_TYPE,
          retired: T.nilable(T::Boolean),
          include_archived_projects: T.nilable(T::Boolean),
        )
        .returns(ShotgridApiRuby::Entity)
    end
    def find(id, fields: nil, retired: nil, include_archived_projects: nil)
      params = Params.new

      params.add_fields(fields)
      params.add_options(retired, include_archived_projects)

      resp = @connection.get(id.to_s, params)
      resp_body = JSON.parse(resp.body)

      if resp.status >= 300
        raise ShotgridCallError.new(
                message: "Error while getting #{type}: #{resp_body['errors']}",
                response: resp,
              )
      end

      entity = resp_body['data']
      Entity.new(
        type: entity['type'],
        attributes: OpenStruct.new(entity['attributes']),
        relationships: entity['relationships'],
        id: entity['id'],
        links: entity['links'],
      )
    end

    sig do
      params(attributes: T::Hash[T.any(String, Symbol), T.untyped])
        .returns(ShotgridApiRuby::Entity)
    end
    def create(attributes)
      resp =
        @connection.post('', attributes.to_json) do |req|
          req.headers['Content-Type'] = 'application/json'
        end

      resp_body = JSON.parse(resp.body)

      if resp.status >= 300
        raise ShotgridCallError.new(
                response: resp,
                message:
                  "Error while creating #{type} with #{attributes}: #{
                    resp_body['errors']
                  }",
              )
      end

      entity = resp_body['data']
      Entity.new(
        type: entity['type'],
        attributes: OpenStruct.new(entity['attributes']),
        relationships: entity['relationships'],
        id: entity['id'],
        links: entity['links'],
      )
    end

    sig do
      params(id: Integer, changes: T::Hash[T.any(String, Symbol), T.untyped])
        .returns(ShotgridApiRuby::Entity)
    end
    def update(id, changes)
      return find(id) if changes.empty?

      resp =
        @connection.put(id.to_s, changes.to_json) do |req|
          req.headers['Content-Type'] = 'application/json'
        end

      resp_body = JSON.parse(resp.body)

      if resp.status >= 300
        raise ShotgridCallError.new(
                response: resp,
                message:
                  "Error while updating #{type}##{id} with #{changes}: #{
                    resp_body['errors']
                  }",
              )
      end

      entity = resp_body['data']
      Entity.new(
        type: entity['type'],
        attributes: OpenStruct.new(entity['attributes']),
        relationships: entity['relationships'],
        id: entity['id'],
        links: entity['links'],
      )
    end

    sig { params(id: Integer).returns(TrueClass) }
    def delete(id)
      resp =
        @connection.delete(id.to_s) do |req|
          req.headers['Content-Type'] = 'application/json'
        end

      if resp.status >= 300
        resp_body = JSON.parse(resp.body)
        raise ShotgridCallError.new(
                response: resp,
                message:
                  "Error while deleting #{type}##{id}: #{resp_body['errors']}",
              )
      end

      true
    end

    sig { params(id: Integer).returns(TrueClass) }
    def revive(id)
      resp = @connection.post("#{id}?revive=true")

      if resp.status >= 300
        resp_body = JSON.parse(resp.body)
        raise ShotgridCallError.new(
                response: resp,
                message:
                  "Error while reviving #{type}##{id}: #{resp_body['errors']}",
              )
      end

      true
    end

    sig do
      params(
          fields: Params::FIELDS_TYPE,
          logical_operator: Params::LOGICAL_OPERATOR_TYPE,
          sort: Params::SORT_TYPE,
          filter: Params::FILTERS_FIELD_TYPE,
          page: Params::PAGE_TYPE,
          page_size: Params::PAGE_SIZE_TYPE,
          retired: T.nilable(T::Boolean),
          include_archived_projects: T.nilable(T::Boolean),
        )
        .returns(T::Array[Entity])
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
        raise ShotgridCallError.new(
                response: resp,
                message: "Error while getting #{type}: #{resp_body['errors']}",
              )
      end

      resp_body['data'].map do |entity|
        Entity.new(
          type: entity['type'],
          attributes: OpenStruct.new(entity['attributes']),
          relationships: entity['relationships'],
          id: entity['id'],
          links: entity['links'],
        )
      end
    end

    sig do
      params(
          fields: Params::FIELDS_TYPE,
          logical_operator: Params::LOGICAL_OPERATOR_TYPE,
          sort: Params::SORT_TYPE,
          filter: Params::FILTERS_FIELD_TYPE,
          page: Params::PAGE_TYPE,
          page_size: Params::PAGE_SIZE_TYPE,
          retired: T.nilable(T::Boolean),
          include_archived_projects: T.nilable(T::Boolean),
        )
        .returns(T::Array[Entity])
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
        raise ShotgridCallError.new(
                response: resp,
                message: "Error while getting #{type}: #{resp_body['errors']}",
              )
      end

      resp_body['data'].map do |entity|
        Entity.new(
          type: entity['type'],
          attributes: OpenStruct.new(entity['attributes']),
          relationships: entity['relationships'],
          id: entity['id'],
          links: entity['links'],
        )
      end
    end

    sig { returns(Schema) }
    def schema_client
      @schema_client ||= Schema.new(connection, type, @base_url_prefix)
    end

    sig { returns(OpenStruct) }
    def schema
      schema_client.read
    end

    sig { returns(OpenStruct) }
    def fields
      schema_client.fields
    end

    sig { returns(Summarize) }
    def summary_client
      @summary_client ||= Summarize.new(connection, type, @base_url_prefix)
    end

    sig do
      params(
          filter: Params::FILTERS_FIELD_TYPE,
          logical_operator: Params::LOGICAL_OPERATOR_TYPE,
        )
        .returns(T.untyped)
    end
    def count(filter: nil, logical_operator: 'and')
      summary_client.count(filter: filter, logical_operator: logical_operator)
    end

    sig do
      params(
          filter: Params::FILTERS_FIELD_TYPE,
          grouping: Params::GROUPING_FIELD_TYPE,
          summary_fields: Params::SUMMARY_FILEDS_TYPE,
          logical_operator: Params::LOGICAL_OPERATOR_TYPE,
          include_archived_projects: T.nilable(T::Boolean),
        )
        .returns(Summarize::Summary)
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
