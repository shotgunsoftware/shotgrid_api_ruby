describe ShotgridApiRuby::Entity, :vcr do
  in_context 'with vcr values' do
    subject(:entity) { shotgrid_client.assets.first }

    it 'exposes the type' do
      expect(entity.type).to eq('Asset')
    end

    it 'exposes the id' do
      expect(entity.id).not_to be_nil
    end

    it 'exposes the links' do
      expect(entity.links['self']).not_to be_nil
    end

    it 'exposes the relationships' do
      expect(entity.relationships['project']['data']).not_to be_nil
    end

    it 'exposes the attributes' do
      expect(entity.attributes.description).not_to be_nil
    end

    describe 'method_missing' do
      context 'when the attribute exists' do
        it 'responds to' do
          expect(entity.respond_to?(:description)).to be_truthy
        end

        it 'generates a new method' do
          expect(entity).to receive(:method_missing)
            .with(:description)
            .once
            .and_call_original

          entity.description
          expect(entity.description).not_to be_nil
        end
      end
    end
  end
end
