describe ShotgridApiRuby::Client do
  in_context 'with vcr values' do
    it 'exposes preferences' do
      expect(shotgrid_client.preferences).to be_a ShotgridApiRuby::Preferences
    end

    it 'exposes server_info' do
      expect(shotgrid_client.server_info).to be_a ShotgridApiRuby::ServerInfo
    end

    it 'exposes entities' do
      expect(shotgrid_client.entities(:Asset)).to be_a ShotgridApiRuby::Entities
    end

    describe 'method_missing' do
      it 'generates a method' do
        expect(shotgrid_client).to receive(:method_missing)
          .once
          .with(:asset)
          .and_call_original

        shotgrid_client.asset
        expect(shotgrid_client.asset).to be_a(ShotgridApiRuby::Entities)
        expect(shotgrid_client.asset.type).to eq('Asset')
        shotgrid_client.Asset
      end

      it 'accepts plurals' do
        expect(shotgrid_client).to receive(:method_missing)
          .once
          .with(:assets)
          .and_call_original

        shotgrid_client.assets
        expect(shotgrid_client.assets).to be_a(ShotgridApiRuby::Entities)
        expect(shotgrid_client.assets.type).to eq('Asset')
        shotgrid_client.Asset
      end
    end

    describe 'respond_to_missing' do
      it 'matches everything' do
        expect(shotgrid_client.respond_to?(SecureRandom.hex)).to be_truthy
      end
    end
  end
end
