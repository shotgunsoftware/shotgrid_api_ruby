# frozen_string_literal: true

describe ShotgridApiRuby::Entities, :vcr do
  in_context 'with vcr values' do
    describe 'create' do
      subject(:create) { shotgrid_client.assets.create(attributes) }

      context "when there's faulty request" do
        let(:attributes) { { not_existing_field: 1234 } }
        it 'raises an error' do
          expect { create }.to raise_error(StandardError, /Asset.*1234/)
        end
      end

      context 'with a valid creation' do
        let(:description) { 'This is a desc' }

        let(:attributes) do
          { description: description, project: { id: 122, type: :Project } }
        end

        it 'returns a valid entity' do
          entity = create
          expect(entity.id).not_to be_nil
          expect(entity.description).to eq(description)
          expect(entity.relationships['project']['data']['id']).to eq(122)
          expect(entity.type).to eq('Asset')
        ensure
          shotgrid_client.assets.delete(entity.id) if entity
        end

        it 'creates the entity' do
          previous_count = shotgrid_client.assets.all.size
          entity = create
          next_count = shotgrid_client.assets.all.size

          expect(next_count - previous_count).to eq(1)
        ensure
          shotgrid_client.assets.delete(entity.id) if entity
        end
      end
    end

    describe 'delete' do
      subject(:delete) { shotgrid_client.assets.delete(id) }

      context 'when the entity does not exists' do
        let(:id) { 400_000 }
        it 'raises an error' do
          expect { delete }.to raise_error(StandardError, /Asset##{id}/)
        end
      end

      context 'when the entity exists' do
        let(:id) do
          entity =
            shotgrid_client.assets.create(project: { type: 'Project', id: 122 })
          entity.id
        end

        it 'returns true' do
          expect(delete).to be_truthy
        end

        it 'delete the entity' do
          expect { delete }.to change {
            shotgrid_client.assets.first(filter: { id: id })
          }.to(nil)
        end
      end
    end

    describe 'update' do
      subject(:update) { shotgrid_client.assets.update(id, changes) }
      context "when the entity doesn't exist" do
        let(:id) { 400_000 }
        let(:changes) { { description: 'NOPE' } }
        it 'raises an error' do
          expect { update }.to raise_error(StandardError, /Asset##{id}/)
        end
      end

      context 'when the entity exists' do
        let(:id) do
          entity =
            shotgrid_client.assets.create(
              { project: { type: :Project, id: 122 }, description: 'old' },
            )
          entity.id
        end

        after { shotgrid_client.assets.delete(id) }

        context 'with empty changes' do
          let(:changes) { {} }
          it 'returns the entity' do
            entity = update

            expect(entity.type).to eq('Asset')
            expect(entity.id).to eq(id)
            expect(entity.description).to eq('old')
          end
        end

        context 'with changes' do
          let(:changes) { { description: 'new' } }

          it 'changes the entity' do
            expect { update }.to change {
              shotgrid_client.assets.find(id).description
            }.from('old').to('new')
          end

          it 'returns the changed entity' do
            entity = update

            expect(entity.id).to eq(id)
            expect(entity.description).to eq('new')
          end
        end
      end
    end

    describe 'revive' do
      subject(:revive) { shotgrid_client.assets.revive(id) }

      context "when the entity doesn't exist" do
        let(:id) { 400_000 }
        it 'raises an error' do
          expect { revive }.to raise_error(StandardError, /Asset##{id}/)
        end
      end

      context 'when the entity exists' do
        let(:id) do
          entity =
            shotgrid_client.assets.create(
              { project: { type: :Project, id: 122 }, description: 'old' },
            )
          entity.id
        end

        before { shotgrid_client.assets.delete(id) }

        after { shotgrid_client.assets.delete(id) }

        it 'returns true' do
          expect(revive).to be_truthy
        end

        it 'revive the entity' do
          expect { revive }.to change {
            shotgrid_client.assets.first(filter: { id: id })&.description
          }.from(nil).to('old')
        end
      end
    end

    describe 'find' do
      subject(:find) do
        shotgrid_client.assets.find(id, retired: retired, fields: fields)
      end

      let(:retired) { false }
      let(:fields) { nil }

      context 'when the entity does not exist' do
        let(:id) { 400_000 }

        it 'raises an error' do
          expect { find }.to raise_error(StandardError, /Asset/)
        end
      end

      context 'when the entity exists' do
        let(:id) do
          entity =
            shotgrid_client.assets.create(
              { project: { type: :Project, id: 122 }, description: 'old' },
            )
          entity.id
        end

        after { shotgrid_client.assets.delete(id) }

        it 'returns the right entity' do
          expect(find.type).to eq('Asset')
          expect(find.id).to eq(id)
          expect(find.description).to eq('old')
        end
      end

      context 'when the entity is retired' do
        let(:id) do
          entity =
            shotgrid_client.assets.create(
              { project: { type: :Project, id: 122 }, description: 'old' },
            )
          entity.id
        end

        let(:retired) { true }

        before { shotgrid_client.assets.delete(id) }
        it 'is findable when retired is specified' do
          expect(find.id).to eq(id)
        end
      end

      context 'when the fields are specified' do
        let(:fields) { [:description] }
        let(:id) do
          entity =
            shotgrid_client.assets.create(
              { project: { type: :Project, id: 122 }, description: 'old' },
            )
          entity.id
        end

        after { shotgrid_client.assets.delete(id) }
        it 'only returns specified fields' do
          expect(find.description).to eq('old')
          expect(find.id).to eq(id)
          expect { find.code }.to raise_error(NoMethodError, /code/)
        end
      end
    end

    describe 'first' do
      let(:shotgrid_assets) { shotgrid_client.assets }

      it 'forward to all' do
        expect(shotgrid_assets).to receive(:all)
          .with(
            fields: :fields,
            sort: :sort,
            filter: :filter,
            retired: :retired,
            include_archived_projects: :include_archived_projects,
            logical_operator: :logical_operator,
            page_size: 1,
          )
          .and_return([:first])
        expect(
          shotgrid_assets.first(
            fields: :fields,
            sort: :sort,
            filter: :filter,
            retired: :retired,
            include_archived_projects: :include_archived_projects,
            logical_operator: :logical_operator,
          ),
        ).to eq(:first)
      end
    end

    describe 'all' do
      subject(:all) do
        shotgrid_client.assets.all(
          fields: fields,
          logical_operator: logical_operator,
          sort: sort,
          filter: filter,
          page: page,
          page_size: page_size,
          retired: retired,
        )
      end

      let(:fields) { nil }
      let(:logical_operator) { 'and' }
      let(:sort) { nil }
      let(:filter) { nil }
      let(:page) { nil }
      let(:page_size) { nil }
      let(:retired) { nil }

      context "when there's an error" do
        let(:filter) { { not_existing_field: 'NOPE' } }

        it 'raises an error' do
          expect { all }.to raise_error(StandardError, /Asset/)
        end
      end

      context "when there's no errors" do
        it 'returns an array of entities' do
          expect(all.size).to be >= 1
          expect(all.first.type).to eq('Asset')
          expect(all.first.description).not_to be_nil
          expect(all.first.code).not_to be_nil
        end
      end

      describe 'fields' do
        let(:fields) { [:description] }

        it 'returns only required fields' do
          expect(all.first.description).not_to be_empty
          expect { all.first.code }.to raise_error(NoMethodError, /code/)
        end

        it 'always returns the id' do
          expect(all.first.id).not_to be_nil
        end
      end

      describe 'logical_operator' do
        let(:filter) { { conditions: [%w[id is 1226], %w[id is 1227]] } }

        context 'when the logical_operator is specified' do
          let(:logical_operator) { 'or' }

          it 'apply the right logical operator' do
            expect(all.size).not_to eq(0)
          end
        end

        it 'applies "and" by default' do
          expect(all.size).to eq(0)
        end
      end

      describe 'sort' do
        let(:sort) { { code: :desc } }
        let(:fields) { [:code] }

        it 'sorts by the sorting param' do
          expect(all.map(&:code)).to eq(
            all.map(&:code).sort_by(&:downcase).reverse,
          )
        end
      end

      describe 'filter' do
        let(:filter) do
          first_asset = shotgrid_client.assets.first
          { code: first_asset.code }
        end

        it 'properly filters' do
          expect(all.size).to eq(1)
          expect(all.first.code).to eq(filter[:code])
        end

        context 'when the filters are too complex' do
          let(:shotgrid_assets) { shotgrid_client.assets }
          let(:filter) { { project: { id: 122 } } }
          it 'calls search instead' do
            expect(shotgrid_assets).to receive(:search).and_call_original
            result = shotgrid_assets.all(filter: filter)
            expect(
              result.map { |asset|
                asset.relationships['project']['data']['id']
              }.uniq,
            ).to eq([122])
          end
        end
      end

      describe 'page and page_size' do
        let(:page) { 2 }
        let(:page_size) { 1 }
        let(:sort) { 'code' }

        it 'returns the right items' do
          expect(all.size).to eq(1)
          expect(all.first.id).to eq(
            shotgrid_client.assets.all(sort: sort)[1].id,
          )
        end
      end

      describe 'retired' do
        let(:retired) { true }
        let(:id) do
          entity =
            shotgrid_client.assets.create(
              { project: { type: :Project, id: 122 }, description: 'old' },
            )
          entity.id
        end
        let(:page_size) { 1000 }
        let(:fields) { 'code' }

        before { shotgrid_client.assets.delete(id) }

        it 'returns retired assets' do
          expect(all.map(&:id)).to include(id)
        end
      end
    end

    describe 'search' do
      subject(:search) do
        shotgrid_client.assets.search(
          fields: fields,
          logical_operator: logical_operator,
          sort: sort,
          filter: filter,
          page: page,
          page_size: page_size,
          retired: retired,
        )
      end

      let(:fields) { nil }
      let(:logical_operator) { 'and' }
      let(:sort) { nil }
      let(:filter) { { project: { id: 122 } } }
      let(:page) { nil }
      let(:page_size) { nil }
      let(:retired) { nil }

      context "when there's an error" do
        let(:filter) { { project: { id: 122 }, not_existing_field: 'NOPE' } }

        it 'raises an error' do
          expect { search }.to raise_error(StandardError, /Asset/)
        end
      end

      context "when there's no errors" do
        it 'returns an array of entities' do
          expect(search.size).to be >= 1
          expect(search.first.type).to eq('Asset')
          expect(search.first.description).not_to be_nil
          expect(search.first.code).not_to be_nil
        end
      end

      describe 'fields' do
        let(:fields) { [:description] }

        it 'returns only required fields' do
          expect(search.first.description).not_to be_empty
          expect { search.first.code }.to raise_error(NoMethodError, /code/)
        end

        it 'always returns the id' do
          expect(search.first.id).not_to be_nil
        end
      end

      describe 'logical_operator' do
        let(:filter) { { conditions: [%w[id is 1226], %w[id is 1227]] } }

        context 'when the logical_operator is specified' do
          let(:logical_operator) { 'or' }

          it 'apply the right logical operator' do
            expect(search.size).not_to eq(0)
          end
        end

        it 'applies "and" by default' do
          expect(search.size).to eq(0)
        end
      end

      describe 'sort' do
        let(:sort) { { code: :desc } }
        let(:fields) { [:code] }

        it 'sorts by the sorting param' do
          expect(search.map(&:code)).to eq(
            search.map(&:code).sort_by(&:downcase).reverse,
          )
        end
      end

      describe 'filter' do
        let(:filter) do
          first_asset =
            shotgrid_client.assets.first(filter: { project: { id: 122 } })
          { code: first_asset.code, project: { id: 122 } }
        end

        it 'properly filters' do
          expect(search.size).to eq(1)
          expect(search.first.code).to eq(filter[:code])
        end

        context 'when the filters are too simple' do
          let(:shotgrid_assets) { shotgrid_client.assets }
          let(:filter) do
            first_asset = shotgrid_client.assets.first
            { code: first_asset.code }
          end

          it 'calls all instead' do
            expect(shotgrid_assets).to receive(:all)
              .at_least(:once)
              .and_call_original
            result = shotgrid_assets.search(filter: filter)
            expect(result.first.code).to eq(filter[:code])
          end
        end
      end

      describe 'page and page_size' do
        let(:page) { 2 }
        let(:page_size) { 1 }
        let(:sort) { 'code' }

        it 'returns the right items' do
          expect(search.size).to eq(1)
          expect(search.first.id).to eq(
            shotgrid_client.assets.search(sort: sort, filter: filter)[1].id,
          )
        end
      end

      describe 'retired' do
        let(:retired) { true }
        let(:id) do
          entity =
            shotgrid_client.assets.create(
              { project: { type: :Project, id: 122 }, description: 'old' },
            )
          entity.id
        end
        let(:page_size) { 1000 }
        let(:fields) { 'code' }

        before { shotgrid_client.assets.delete(id) }

        it 'returns retired assets' do
          expect(search.map(&:id)).to include(id)
        end
      end
    end
  end
end
