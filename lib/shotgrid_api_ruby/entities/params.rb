# typed: strict
# frozen_string_literal: true

module ShotgridApiRuby
  class Entities
    class Params
      extend T::Sig
      extend Forwardable

      class TooComplexFiltersError < StandardError
      end

      sig { void }
      def initialize
        @parsed_params = T.let({}, T::Hash[T.any(String, Symbol), T.untyped])
      end

      def_delegators :@parsed_params, :[], :[]=, :delete, :to_h, :each

      SortType =
        T.type_alias do
          T.nilable(
            T.any(
              T::Hash[T.any(String, Symbol), T.any(String, Symbol)],
              T::Array[T.any(String, Symbol)],
              String,
              Symbol,
            ),
          )
        end
      sig { params(sort: SortType).returns(T.nilable(String)) }
      def add_sort(sort)
        return unless sort

        @parsed_params[:sort] =
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

      PageType = T.type_alias { T.nilable(T.any(String, Integer)) }
      PageSizeType = T.type_alias { T.nilable(T.any(String, Integer)) }

      sig do
        params(page: PageType, page_size: PageSizeType)
          .returns(T.nilable(T::Hash[T.untyped, T.untyped]))
      end
      def add_page(page, page_size)
        return unless page || page_size

        page = page.to_i if page
        page_size = page_size.to_i if page_size

        page = 1 if page && page < 1
        @parsed_params[:page] = { size: page_size || 20, number: page || 1 }
      end

      FieldsType =
        T.type_alias do
          T.nilable(T.any(String, Symbol, T::Array[T.any(String, Symbol)]))
        end
      sig { params(fields: FieldsType).returns(String) }
      def add_fields(fields)
        @parsed_params[:fields] =
          fields && !fields.empty? ? [fields].flatten.join(',') : '*'
      end

      sig do
        params(
            return_only: T.nilable(T::Boolean),
            include_archived_projects: T.nilable(T::Boolean),
          )
          .returns(
            T.nilable(
              { return_only: String, include_archived_projects: T::Boolean },
            ),
          )
      end
      def add_options(return_only, include_archived_projects)
        return if return_only.nil? && include_archived_projects.nil?

        @parsed_params[:options] = {
          return_only: return_only ? 'retired' : 'active',
          include_archived_projects: !!include_archived_projects,
        }
      end

      LogicalOperatorType = T.type_alias { T.any(String, Symbol) }
      FiltersFiledType =
        T.type_alias do
          T.nilable(
            T.any(
              T::Array[T.untyped],
              T::Hash[
                T.any(String, Symbol),
                T.any(
                  String,
                  Symbol,
                  Integer,
                  Float,
                  T::Array[T.any(String, Symbol, Integer, Float)],
                  T::Hash[
                    T.any(String, Symbol),
                    T.any(
                      String,
                      Symbol,
                      Integer,
                      Float,
                      T::Array[T.any(String, Symbol, Integer, Float)],
                      T.untyped,
                    )
                  ],
                  T.untyped,
                )
              ],
              T::Hash[
                T.any(String, Symbol),
                T.any(
                  String,
                  Symbol,
                  Integer,
                  Float,
                  T::Array[T.any(String, Symbol, Integer, Float)],
                )
              ],
            ),
          )
        end
      sig do
        params(filters: FiltersFiledType, logical_operator: LogicalOperatorType)
          .returns(
            T.nilable(
              T.any(
                T::Hash[String, String],
                {
                  conditions:
                    T.any(
                      T::Array[T.any(String, Symbol, Integer, Float)],
                      T::Array[T.untyped],
                    ),
                  logical_operator: String,
                },
              ),
            ),
          )
      end
      def add_filter(filters, logical_operator = 'and')
        return unless filters

        # cast are here because Sorbet is confused by the madness filters can be
        @parsed_params[:filter] =
          if (self.class.filters_are_simple?(filters))
            translate_simple_filters_to_sg(
              T.cast(
                filters,
                T::Hash[
                  T.any(String, Symbol),
                  T.any(
                    String,
                    Symbol,
                    Integer,
                    Float,
                    T::Array[T.any(String, Symbol, Integer, Float)],
                  )
                ],
              ),
            )
          elsif filters.is_a? Hash
            filters =
              T.cast(
                T.unsafe(filters),
                T::Hash[
                  T.any(String, Symbol),
                  T.any(
                    String,
                    Symbol,
                    Integer,
                    Float,
                    T::Array[T.any(String, Symbol, Integer, Float)],
                    T::Hash[
                      T.any(String, Symbol),
                      T.any(
                        String,
                        Symbol,
                        Integer,
                        Float,
                        T::Array[T.any(String, Symbol, Integer, Float)],
                        T.untyped,
                      )
                    ],
                    T.untyped,
                  )
                ],
              )
            {
              conditions:
                filters[:conditions] || filters['conditions'] ||
                  translate_complex_filters_to_sg(filters),
              logical_operator:
                filters[:logical_operator] || filters['logical_operator'] ||
                  logical_operator.to_s,
            }
          else
            { conditions: filters, logical_operator: logical_operator.to_s }
          end
      end

      GroupingFieldType =
        T.type_alias do
          T.nilable(
            T.any(
              T::Array[T::Array[T.any(String, Symbol)]],
              T::Hash[
                String,
                T.any(
                  String,
                  Symbol,
                  { type: String },
                  { 'type' => String },
                  { direction: String },
                  { 'direction' => String },
                  { type: String, direction: String },
                  { :type => String, 'direction' => String },
                  { 'type' => String, :direction => String },
                  { 'type' => String, 'direction' => String },
                )
              ],
            ),
          )
        end
      sig { params(grouping: GroupingFieldType).returns(T.untyped) }
      def add_grouping(grouping)
        return unless grouping

        if grouping.is_a? Array
          @parsed_params[:grouping] = grouping
          return
        end

        @parsed_params[:grouping] =
          grouping.each_with_object([]) do |(key, options), result|
            if options.is_a? Hash
              result << {
                field: key.to_s,
                type: options[:type]&.to_s || options['type']&.to_s || 'exact',
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

      SummaryFiledsType =
        T.type_alias do
          T.nilable(
            T.any(
              T::Array[
                T::Hash[
                  T.any(String, Symbol),
                  T::Hash[T.any(String, Symbol), T.any(String, Symbol)]
                ]
              ],
              T::Hash[T.any(String, Symbol), T.any(String, Symbol)],
            ),
          )
        end
      sig do
        params(summary_fields: SummaryFiledsType)
          .returns(T.nilable(T::Array[T::Hash[T.untyped, T.untyped]]))
      end
      def add_summary_fields(summary_fields)
        return unless summary_fields

        if summary_fields.is_a? Array
          @parsed_params[:summary_fields] = summary_fields
          return
        end

        if summary_fields.is_a? Hash
          @parsed_params[:summary_fields] =
            summary_fields.map { |k, v| { field: k.to_s, type: v.to_s } }
        end
      end

      sig { params(filters: FiltersFiledType).returns(T::Boolean) }
      def self.filters_are_simple?(filters)
        return false unless filters
        return false if filters.is_a? Array

        return false if filters[:conditions] || filters['conditions']

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

      sig do
        params(
            filters:
              T::Hash[
                T.any(String, Symbol),
                T.any(
                  String,
                  Symbol,
                  Integer,
                  Float,
                  T::Array[T.any(String, Symbol, Integer, Float)],
                )
              ],
          )
          .returns(T::Hash[String, String])
      end
      def translate_simple_filters_to_sg(filters)
        filters.map do |field, value|
          [
            field.to_s,
            value.is_a?(Array) ? value.map(&:to_s).join(',') : value.to_s,
          ]
        end.to_h
      end

      sig do
        params(
            filters:
              T.any(
                T::Array[T.untyped],
                T::Hash[
                  T.any(String, Symbol),
                  T.any(
                    String,
                    Symbol,
                    Integer,
                    Float,
                    T::Array[T.any(String, Symbol, Integer, Float)],
                    T::Hash[
                      T.any(String, Symbol),
                      T.any(
                        String,
                        Symbol,
                        Integer,
                        Float,
                        T::Array[T.any(String, Symbol, Integer, Float)],
                        T.untyped,
                      )
                    ],
                    T.untyped,
                  )
                ],
              ),
          )
          .returns(
            T::Array[
              T.any(
                T::Array[T.any(String, Symbol, Integer, Float)],
                T::Array[T.untyped],
              )
            ],
          )
      end
      def translate_complex_filters_to_sg(filters)
        # We don't know how to translate anything but hashes
        return filters unless filters.is_a?(Hash)

        filters.each_with_object([]) do |item, result|
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
