describe ShotgunApiRuby::Entities::Summarize, :vcr do
  in_context 'with vcr values' do
    describe 'count' do
      it 'calls summarize' do
        expect(shotgun_client.assets.summary_client).to receive(:summarize)
          .with(
            filter: {
              project: {
                id: 155,
              },
            },
            logical_operator: 'and',
            summary_fields: [{ type: :record_count, field: 'id' }],
          )
          .and_call_original

        shotgun_client.assets.count(
          filter: {
            project: {
              id: 155,
            },
          },
          logical_operator: 'and',
        )
      end

      it 'returns a number' do
        expect(
          shotgun_client.assets.count(filter: { project: { id: 155 } }),
        ).to be > 0
      end
    end

    describe 'summarize' do
      subject(:summarize) do
        shotgun_client.assets.summarize(
          filter: filter,
          grouping: grouping,
          summary_fields: summary_fields,
          logical_operator: logical_operator,
        )
      end

      let(:filter) { nil }
      let(:grouping) { nil }
      let(:summary_fields) { { id: :count } }
      let(:logical_operator) { 'and' }

      context "when there's an error" do
        let(:summary_fields) { { not_existing_field: :not_possible } }

        it 'raise an error' do
          expect { summarize }.to raise_error(StandardError, /Asset/)
        end
      end

      it 'works normaly' do
        expect(summarize.summaries).not_to be_empty
        expect(summarize.summaries['id']).to be >= 0
        expect(summarize.groups).to eq([])
      end
    end
  end
end
