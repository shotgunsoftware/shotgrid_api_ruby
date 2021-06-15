# frozen_string_literal: true

describe ShotgunApiRuby::Entities::Params do
  subject(:params) { described_class.new }

  describe '#add_grouping' do
    subject(:add_grouping) { params.add_grouping(grouping) }

    context "when there's not grouping" do
      let(:grouping) { nil }
      it "doesn't fail" do
        expect { add_grouping }.not_to raise_error
      end
    end

    context 'when adding an array' do
      let(:grouping) { Array.new(Random.rand(2..4)) { Faker::Tea.variety } }
      it 'uses it raw' do
        add_grouping

        expect(params[:grouping]).to eq(grouping)
      end
    end

    context 'with string option' do
      let(:grouping) { { :field1 => :asc, 'field2' => 'desc' } }
      it 'uses the value as a direction' do
        add_grouping

        expect(params[:grouping].map { |e| [e[:field], e[:direction]] }).to eq(
          [%w[field1 asc], %w[field2 desc]],
        )
      end

      it 'sets the type to exact' do
        add_grouping

        expect(params[:grouping].map { |e| e[:type] }.uniq).to eq(['exact'])
      end
    end

    context 'with hash options' do
      it 'reads type' do
        params.add_grouping(
          { :field1 => { type: 'aa' }, 'field2' => { 'type' => :lol } },
        )
        expect(params[:grouping].map { |e| [e[:field], e[:type]] }).to eq(
          [%w[field1 aa], %w[field2 lol]],
        )
      end

      it 'defaults type as exact' do
        params.add_grouping(field: {})

        expect(params[:grouping].first[:type]).to eq('exact')
      end

      it 'reads direction' do
        params.add_grouping(
          {
            :field1 => {
              direction: 'aa',
            },
            'field2' => {
              'direction' => :lol,
            },
          },
        )
        expect(params[:grouping].map { |e| [e[:field], e[:direction]] }).to eq(
          [%w[field1 aa], %w[field2 lol]],
        )
      end

      it 'defaults direction as asc' do
        params.add_grouping(field: {})

        expect(params[:grouping].first[:direction]).to eq('asc')
      end
    end

    context 'when setting grouping twice' do
      it 'takes the last one' do
        params.add_grouping(['aa'])
        params.add_grouping(['bb'])

        expect(params[:grouping]).to eq(['bb'])
      end
    end
  end

  describe '#add_summary_fields' do
    subject(:add_summary_fields) { params.add_summary_fields(summary_fields) }

    context 'with no summary_fields' do
      let(:summary_fields) { nil }
      it 'does not fail' do
        expect { add_summary_fields }.not_to raise_error
      end
    end

    context 'when the summary_fields is an array' do
      let(:summary_fields) { ['aa'] }

      it 'uses it raw' do
        add_summary_fields
        expect(params[:summary_fields]).to eq(['aa'])
      end
    end

    context 'when the summary fields is a hash' do
      let(:summary_fields) { { :field1 => :count, 'field2' => 'sum' } }

      it 'translate it to shotgun summary_fields' do
        add_summary_fields

        expect(params[:summary_fields]).to eq(
          [
            { field: 'field1', type: 'count' },
            { field: 'field2', type: 'sum' },
          ],
        )
      end
    end

    context 'when setting the summary_fields multiple times' do
      it 'uses the last' do
        params.add_summary_fields(['aa'])
        params.add_summary_fields(['bb'])

        expect(params[:summary_fields]).to eq(['bb'])
      end
    end
  end

  describe '#add_sort' do
    let(:sort_string) { Faker::Tea.variety }

    context 'when the sort is a string' do
      it 'sets the sort to the exact same string' do
        params.add_sort(sort_string)
        expect(params[:sort]).to eq(sort_string)
      end
    end

    context 'when the sort is an array' do
      let(:sort_array) { Array.new(Random.rand(2..4)) { Faker::Tea.variety } }

      it 'formats the array into comma separated string' do
        params.add_sort(sort_array)
        expect(params[:sort]).to eq(sort_array.join(','))
      end
    end

    context 'when the sort is a hash' do
      let(:sort_hash) do
        {
          'field_1' => 'asc',
          'field_2' => 'desc',
          :field3 => :asc,
          :field4 => :desc,
        }
      end

      it 'transform the hash to comma separated string' do
        params.add_sort(sort_hash)
        expect(params[:sort]).to eq('field_1,-field_2,field3,-field4')
      end
    end

    context 'when setting the sort twice' do
      it 'override the previous value' do
        params.add_sort(SecureRandom.hex)
        params.add_sort('aaaaa')
        expect(params[:sort]).to eq('aaaaa')
      end
    end

    context 'when sort is empty' do
      it 'does not fail' do
        expect { params.add_sort(nil) }.not_to raise_error
        expect(params[:sort]).to be_nil
      end
    end
  end

  describe '#add_page' do
    context 'when the page is empty' do
      it 'does not fail' do
        expect { params.add_page(nil, nil) }.not_to raise_error
        expect(params[:page]).to be_nil
      end
    end

    context 'when both page_number and size are present' do
      let(:page_number) { Random.rand(1..100) }
      let(:page_size) { Random.rand(1..100) }

      it 'sets the params' do
        params.add_page(page_number, page_size)
        expect(params[:page][:size]).to eq(page_size)
        expect(params[:page][:number]).to eq(page_number)
      end
    end

    context 'when the params are strings' do
      let(:page_number) { Random.rand(1..100) }
      let(:page_size) { Random.rand(1..100) }

      it 'sets the params' do
        params.add_page(page_number.to_s, page_size.to_s)
        expect(params[:page][:size]).to eq(page_size)
        expect(params[:page][:number]).to eq(page_number)
      end
    end

    context 'when the page number is lower than 1' do
      let(:page_number) { Random.rand(-20..-1) }

      it 'sets the default value' do
        params.add_page(page_number, 20)
        expect(params[:page][:number]).to eq(1)
        params.add_page(0, 20)
        expect(params[:page][:number]).to eq(1)
      end
    end

    context 'when page is nil' do
      it 'sets the page to 1' do
        params.add_page(nil, 20)
        expect(params[:page][:number]).to eq(1)
      end
    end

    context 'when size is nil' do
      it 'sets the size to 20' do
        params.add_page(1, nil)
        expect(params[:page][:size]).to eq(20)
      end
    end

    context 'when setting the page twice' do
      it 'override the previous value' do
        params.add_page(3, 3)
        params.add_page(5, 5)
        expect(params[:page][:size]).to eq(5)
        expect(params[:page][:number]).to eq(5)
      end
    end
  end

  describe '#add_fields' do
    context 'when the fields are a string' do
      let(:string_fields) { Faker::Tea.variety }

      it 'sets the fields' do
        params.add_fields(string_fields)
        expect(params[:fields]).to eq(string_fields)
      end
    end

    context 'when the fields are an array' do
      let(:array_fields) { ['a', :b] }

      it 'sets the fields' do
        params.add_fields(array_fields)
        expect(params[:fields]).to eq('a,b')
      end
    end

    context 'when the fields are nil' do
      it 'sets the fields to all' do
        params.add_fields(nil)
        expect(params[:fields]).to eq('*')
      end
    end

    context 'when the fields are blank' do
      it 'sets the fields to all' do
        params.add_fields('')
        expect(params[:fields]).to eq('*')
      end
    end

    context 'when the fields are empty' do
      it 'sets the fields to all' do
        params.add_fields([])
        expect(params[:fields]).to eq('*')
      end
    end

    context 'when setting the fields multiple times' do
      it 'override the previous value' do
        params.add_fields('a')
        params.add_fields('b')
        expect(params[:fields]).to eq('b')
      end
    end
  end

  describe '#add_options' do
    context 'when both options are nil' do
      it "doesn't fails" do
        params.add_options(nil, nil)
        expect(params[:options]).to be_nil
      end
    end

    context 'when both options are set' do
      it 'sets the options correctly' do
        params.add_options(true, true)
        expect(params[:options][:return_only]).to eq('retired')
        expect(params[:options][:include_archived_projects]).to be_truthy
      end
    end

    context 'when return_only is nil' do
      it 'sets the default value' do
        params.add_options(nil, false)
        expect(params[:options][:return_only]).to eq('active')
        expect(params[:options][:include_archived_projects]).to be_falsy
      end
    end

    context 'when include_archived_projects is nil' do
      it 'sets the default value' do
        params.add_options(false, nil)
        expect(params[:options][:return_only]).to eq('active')
        expect(params[:options][:include_archived_projects]).to be_falsy
      end
    end

    context 'when setting the options multiple times' do
      it 'override the previous value' do
        params.add_options(false, nil)
        params.add_options(true, true)
        expect(params[:options][:return_only]).to eq('retired')
        expect(params[:options][:include_archived_projects]).to be_truthy
      end
    end
  end

  describe 'filter management' do
    describe '::filters_are_simple?' do
      subject(:filters_are_simple_call) do
        described_class.filters_are_simple?(filters)
      end

      context 'when filters are an array' do
        let(:filters) { [] }
        it 'is not simple' do
          expect(filters_are_simple_call).to be_falsy
        end
      end

      context 'when filters are an hash' do
        context 'when all keys are string or integer or symbols' do
          let(:filters) do
            (Array.new(30) { [1, 'a', :a].sample }).each_with_object(
              {},
            ) { |value, result| result[SecureRandom.hex] = value }
          end

          it 'is simple' do
            expect(filters_are_simple_call).to be_truthy
          end
        end

        context 'when at least one of the keys is named "conditions"' do
          let(:filters) { { 'conditions' => 'aaa' } }

          it 'is complex' do
            expect(filters_are_simple_call).to be_falsy
          end
        end

        context 'when at least one of the keys is named :conditions' do
          let(:filters) { { conditions: 'aaa' } }

          it 'is complex' do
            expect(filters_are_simple_call).to be_falsy
          end
        end

        context 'when the value is an array string or integer or symbols' do
          let(:filters) { { a: Array.new(30) { [1, 'a', :a].sample } } }

          it 'is simple' do
            expect(filters_are_simple_call).to be_truthy
          end
        end

        context 'when one value is something else' do
          let(:filters) { { a: 1, b: {}, c: :c } }

          it 'is complex' do
            expect(filters_are_simple_call).to be_falsy
          end
        end

        context 'when one value in an array is something else' do
          let(:filters) { { a: 1, b: [1, 'a'], c: :c, d: [{}] } }

          it 'is complex' do
            expect(filters_are_simple_call).to be_falsy
          end
        end
      end
    end

    describe 'simple filter translation' do
      subject(:translation_call) do
        params.send(:translate_simple_filters_to_sg, filters)
      end

      context "when the keys aren't strings" do
        let(:filters) { { :a => 'a', 1 => '1' } }

        it 'stringifies the keys' do
          expect(translation_call).to eq({ 'a' => 'a', '1' => '1' })
        end
      end

      context 'when translating simple values' do
        let(:filters) { { a: 'a', b: :b, c: 3 } }

        it 'stringifies the values' do
          expect(translation_call).to eq({ 'a' => 'a', 'b' => 'b', 'c' => '3' })
        end
      end

      context 'when translating an array' do
        let(:filters) { { a: ['a', :b, 3] } }

        it 'stringifies and joins the values' do
          expect(translation_call).to eq({ 'a' => 'a,b,3' })
        end
      end
    end

    describe 'complex filter translation' do
      subject(:translation_call) do
        params.send(:translate_complex_filters_to_sg, filters)
      end

      context 'when the filters are an array' do
        let(:filters) { [:a] }

        it 'returns the array' do
          expect(translation_call).to eq(filters)
        end
      end

      describe 'string translation' do
        let(:filters) { { a: 'string' } }

        it 'translates to "is" form' do
          expect(translation_call).to eq([%w[a is string]])
        end
      end

      describe 'symbol translation' do
        let(:filters) { { a: :symbol } }

        it 'translates to "is" form' do
          expect(translation_call).to eq([['a', 'is', :symbol]])
        end
      end

      describe 'integer translation' do
        let(:filters) { { a: 4 } }

        it 'translates to "is" form' do
          expect(translation_call).to eq([['a', 'is', 4]])
        end
      end

      describe 'float translation' do
        let(:filters) { { a: 3.14 } }

        it 'translates to "is" form' do
          expect(translation_call).to eq([['a', 'is', 3.14]])
        end
      end

      describe 'array translation' do
        let(:filters) { { a: [1, 2, 3] } }

        it 'translate to "in" form' do
          expect(translation_call).to eq([['a', 'in', [1, 2, 3]]])
        end
      end

      describe 'when the value is something to complex' do
        let(:filters) { { a: OpenStruct.new(b: :c) } }
        it 'raises an error' do
          expect { translation_call }.to raise_error(
            ShotgunApiRuby::Entities::Params::TooComplexFiltersError,
            /too complex/,
          )
        end
      end

      describe 'when the value is a hash' do
        describe 'subfiled sanitization' do
          context 'when the subfield is already in dot form' do
            let(:filters) { { field: { 'sub.field' => 1 } } }

            it 'does not modify it' do
              expect(translation_call).to eq([['field.sub.field', 'is', 1]])
            end
          end

          let(:filters) { { field: { sub: 1 } } }

          it 'translates the subfield to "dot" form' do
            expect(translation_call).to eq([['field.Field.sub', 'is', 1]])
          end
        end

        context 'when the sub-value is a string' do
          let(:filters) { { entity: { sub: 'string' } } }

          it 'translates to "is" form' do
            expect(translation_call).to eq([%w[entity.Entity.sub is string]])
          end
        end

        context 'when the sub-value is a symbol' do
          let(:filters) { { entity: { sub: :symbol } } }

          it 'translates to "is" form' do
            expect(translation_call).to eq(
              [['entity.Entity.sub', 'is', :symbol]],
            )
          end
        end

        context 'when the sub-value is a integer' do
          let(:filters) { { entity: { sub: 4 } } }

          it 'translates to "is" form' do
            expect(translation_call).to eq([['entity.Entity.sub', 'is', 4]])
          end
        end

        context 'when the sub-value is a float' do
          let(:filters) { { entity: { sub: 2.71 } } }

          it 'translates to "is" form' do
            expect(translation_call).to eq([['entity.Entity.sub', 'is', 2.71]])
          end
        end

        context 'when the sub-value is an array' do
          let(:filters) { { entity: { sub: [1, 2, 3] } } }

          it 'translates to "in" form' do
            expect(translation_call).to eq(
              [['entity.Entity.sub', 'in', [1, 2, 3]]],
            )
          end
        end

        context 'when the sub-value is too complex' do
          let(:filters) { { entity: { sub: {} } } }

          it 'raises an error' do
            expect { translation_call }.to raise_error(
              ShotgunApiRuby::Entities::Params::TooComplexFiltersError,
              /too complex/,
            )
          end
        end
      end
    end

    describe 'add_filter' do
      describe 'simple filters' do
        it 'sets the filters' do
          expect(params).to receive(:translate_simple_filters_to_sg).and_return(
            :simple_translate,
          )
          params.add_filter({ a: 1 })
          expect(params[:filter]).to eq(:simple_translate)
        end
      end

      describe 'complex filters' do
        context 'when the logical operator is specified' do
          it 'sets the filters and logical_operator' do
            expect(params).to receive(:translate_complex_filters_to_sg)
              .and_return(:complex_translate)
            params.add_filter({ a: { b: {} } }, 'or')
            expect(params[:filter][:conditions]).to eq(:complex_translate)
            expect(params[:filter][:logical_operator]).to eq('or')
          end
        end

        it 'sets the filters' do
          expect(params).to receive(:translate_complex_filters_to_sg)
            .and_return(:complex_translate)
          params.add_filter({ a: { b: {} } })
          expect(params[:filter][:conditions]).to eq(:complex_translate)
          expect(params[:filter][:logical_operator]).to eq('and')
        end
      end

      describe 'do not translate filters' do
        describe 'hash form' do
          context 'with conditions symbol' do
            it 'does not translate' do
              params.add_filter({ conditions: 'conditions' })
              expect(params[:filter]).to eq(
                { conditions: 'conditions', logical_operator: 'and' },
              )
            end
          end

          context 'with conditions string' do
            it 'does not translate' do
              params.add_filter({ 'conditions' => 'conditions' })
              expect(params[:filter]).to eq(
                { conditions: 'conditions', logical_operator: 'and' },
              )
            end
          end

          context 'with logical_operator string' do
            it 'does not translate' do
              params.add_filter(
                { :conditions => 'conditions', 'logical_operator' => 'or' },
              )
              expect(params[:filter]).to eq(
                { conditions: 'conditions', logical_operator: 'or' },
              )
            end
          end

          context 'with logical_operator symbol' do
            it 'does not translate' do
              params.add_filter(
                { conditions: 'conditions', logical_operator: 'or' },
              )
              expect(params[:filter]).to eq(
                { conditions: 'conditions', logical_operator: 'or' },
              )
            end
          end
        end

        describe 'array form' do
          context 'when the logical operator is specified' do
            it 'does not translate and uses specified operator' do
              params.add_filter([a: {}], 'or')
              expect(params[:filter]).to eq(
                { conditions: [a: {}], logical_operator: 'or' },
              )
            end
          end

          it 'does not translate' do
            params.add_filter([a: {}])
            expect(params[:filter]).to eq(
              { conditions: [a: {}], logical_operator: 'and' },
            )
          end
        end
      end
    end
  end
end
