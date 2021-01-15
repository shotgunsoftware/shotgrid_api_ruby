describe ShotgunApiRuby::Entities::Schema, :vcr do
  in_context 'with vcr values' do
    describe 'schema read' do
      subject(:schema) { shotgun_client.assets.schema }

      it 'reads the schema' do
        expect(schema.name).to eq('Asset')
      end
    end

    describe 'fields read' do
      subject(:fields) { shotgun_client.assets.fields }

      it 'reads the schema' do
        expect(fields.description.name).to eq('Description')
        expect(fields.description.properties.summary_default).not_to be_nil
      end
    end
  end
end
