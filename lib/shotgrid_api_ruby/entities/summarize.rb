# typed: true
module ShotgridApiRuby
  class Entities
    class Summarize
      Summary = Struct.new(:summaries, :groups)

      def initialize(connection, type, base_url_prefix)
        @connection = connection.dup
        @type = type
        @connection.url_prefix = "#{base_url_prefix}/entity/#{type}/_summarize"
      end
      attr_reader :type, :connection

      def count(filter: nil, logical_operator: 'and')
        result =
          summarize(
            filter: filter,
            logical_operator: logical_operator,
            summary_fields: [{ type: :record_count, field: 'id' }],
          )
        result.summaries&.[]('id') || 0
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
          resp_body['data']['summaries'],
          resp_body['data']&.[]('groups'),
        )
      end
    end
  end
end
