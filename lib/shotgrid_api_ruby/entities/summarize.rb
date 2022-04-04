# typed: strict
module ShotgridApiRuby
  class Entities
    class Summarize
      extend T::Sig

      class Summary < T::Struct
        const :summaries, T.nilable(T::Hash[T.untyped, T.untyped])
        const :groups, T.nilable(T::Array[T.untyped])
      end

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
        @connection.url_prefix =
          T.let("#{base_url_prefix}/entity/#{type}/_summarize", String)
      end

      sig { returns(T.any(String, Symbol)) }
      attr_reader :type
      sig { returns(Faraday::Connection) }
      attr_reader :connection

      sig do
        params(filter: T.untyped, logical_operator: T.untyped)
          .returns(T.untyped)
      end
      def count(filter: nil, logical_operator: 'and')
        result =
          summarize(
            filter: filter,
            logical_operator: logical_operator,
            summary_fields: [{ type: :record_count, field: 'id' }],
          )
        result.summaries&.[]('id') || 0
      end

      sig do
        params(
            filter: Params::FiltersFiledType,
            grouping: Params::GroupingFieldType,
            summary_fields: Params::SummaryFiledsType,
            logical_operator: Params::LogicalOperatorType,
            include_archived_projects: T.nilable(T::Boolean),
          )
          .returns(Summary)
      end
      def summarize(
        filter: nil,
        grouping: nil,
        summary_fields: nil,
        logical_operator: 'and',
        include_archived_projects: nil
      )
        params = Params.new

        params.add_filter(filter, logical_operator)

        params[:filters] = params[:filter] if params[:filter]
        params.delete(:filter)

        params.add_grouping(grouping)
        params.add_summary_fields(summary_fields)
        params.add_options(nil, include_archived_projects)

        resp =
          @connection.post('', params) do |req|
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
                  message:
                    "Error while getting summarize for #{type}: #{resp_body['errors']}",
                )
        end

        Summary.new(
          summaries: resp_body['data']['summaries'],
          groups: resp_body['data']&.[]('groups'),
        )
      end
    end
  end
end
