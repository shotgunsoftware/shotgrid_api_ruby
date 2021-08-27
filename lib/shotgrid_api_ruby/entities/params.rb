# typed: false
# frozen_string_literal: true

module ShotgridApiRuby
  class Entities
    class Params < Hash
      class TooComplexFiltersError < StandardError
      end

      def add_sort(sort)
        return unless sort

        self[:sort] =
          if sort.is_a?(Hash)
            sort
              .map do |field, direction|
                "#{direction.to_s.start_with?('desc') ? '-' : ''}#{field}"
              end
              .join(',')
          else
            [sort].flatten.join(',')
          end
      end

      def add_page(page, page_size)
        return unless page || page_size

        page = page.to_i if page
        page_size = page_size.to_i if page_size

        page = 1 if page && page < 1
        self[:page] = { size: page_size || 20, number: page || 1 }
      end

      def add_fields(fields)
        self[:fields] =
          fields && !fields.empty? ? [fields].flatten.join(',') : '*'
      end

      def add_options(return_only, include_archived_projects)
        return if return_only.nil? && include_archived_projects.nil?

        self[:options] = {
          return_only: return_only ? 'retired' : 'active',
          include_archived_projects: !!include_archived_projects,
        }
      end

      def add_filter(filters, logical_operator = 'and')
        return unless filters

        self[:filter] =
          if (self.class.filters_are_simple?(filters))
            translate_simple_filters_to_sg(filters)
          elsif filters.is_a? Hash
            {
              conditions:
                filters[:conditions] || filters['conditions'] ||
                  translate_complex_filters_to_sg(filters),
              logical_operator:
                filters[:logical_operator] || filters['logical_operator'] ||
                  logical_operator,
            }
          else
            { conditions: filters, logical_operator: logical_operator }
          end
      end

      def add_grouping(grouping)
        return unless grouping

        if grouping.is_a? Array
          self[:grouping] = grouping
          return
        end

        self[:grouping] =
          grouping
            .each
            .with_object([]) do |(key, options), result|
              if options.is_a? Hash
                result << {
                  field: key.to_s,
                  type:
                    options[:type]&.to_s || options['type']&.to_s || 'exact',
                  direction:
                    options[:direction]&.to_s || options['direction']&.to_s ||
                      'asc',
                }
              else
                result << {
                  field: key.to_s,
                  type: 'exact',
                  direction: options.to_s,
                }
              end
            end
      end

      def add_summary_fields(summary_fields)
        return unless summary_fields

        if summary_fields.is_a? Array
          self[:summary_fields] = summary_fields
          return
        end

        if summary_fields.is_a? Hash
          self[:summary_fields] =
            summary_fields.map { |k, v| { field: k.to_s, type: v.to_s } }
        end
      end

      def self.filters_are_simple?(filters)
        return false if filters.is_a? Array

        if filters.is_a?(Hash) &&
             (filters[:conditions] || filters['conditions'])
          return false
        end

        filters.values.all? do |filter_val|
          (
            filter_val.is_a?(Integer) || filter_val.is_a?(String) ||
              filter_val.is_a?(Symbol)
          ) ||
            (
              filter_val.is_a?(Array) &&
                filter_val.all? do |val|
                  val.is_a?(String) || val.is_a?(Symbol) || val.is_a?(Integer)
                end
            )
        end
      end

      private

      def translate_simple_filters_to_sg(filters)
        filters.map do |field, value|
          [
            field.to_s,
            value.is_a?(Array) ? value.map(&:to_s).join(',') : value.to_s,
          ]
        end.to_h
      end

      def translate_complex_filters_to_sg(filters)
        # We don't know how to translate anything but hashes
        return filters if !filters.is_a?(Hash)

        filters
          .each
          .with_object([]) do |item, result|
            field, value = item
            case value
            when String, Symbol, Integer, Float
              result << [field.to_s, 'is', value]
            when Hash
              value.each do |subfield, subvalue|
                sanitized_subfield =
                  if !subfield.to_s.include?('.')
                    "#{field.capitalize}.#{subfield}"
                  else
                    subfield
                  end
                case subvalue
                when String, Symbol, Integer, Float
                  result << ["#{field}.#{sanitized_subfield}", 'is', subvalue]
                when Array
                  result << ["#{field}.#{sanitized_subfield}", 'in', subvalue]
                else
                  raise TooComplexFiltersError,
                        'This case is too complex to auto-translate. Please use shotgrid query syntax.'
                end
              end
            when Array
              result << [field.to_s, 'in', value]
            else
              raise TooComplexFiltersError,
                    'This case is too complex to auto-translate. Please use shotgrid query syntax.'
            end
          end
      end
    end
  end
end
