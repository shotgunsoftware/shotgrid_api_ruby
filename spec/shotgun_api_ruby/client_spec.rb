describe ShotgunApiRuby::Client do
  in_context 'with vcr values' do
    it 'exposes preferences' do
      expect(shotgun_client.preferences).to be_a ShotgunApiRuby::Preferences
    end

    it 'exposes server_info' do
      expect(shotgun_client.server_info).to be_a ShotgunApiRuby::ServerInfo
    end

    it 'exposes entities' do
      expect(shotgun_client.entities(:Asset)).to be_a ShotgunApiRuby::Entities
    end

    describe 'method_missing' do
      it 'generates a method' do
        expect(shotgun_client).to receive(:method_missing)
          .once
          .with(:asset)
          .and_call_original

        shotgun_client.asset
        expect(shotgun_client.asset).to be_a(ShotgunApiRuby::Entities)
        expect(shotgun_client.asset.type).to eq('Asset')
        shotgun_client.Asset
      end

      it 'accepts plurals' do
        expect(shotgun_client).to receive(:method_missing)
          .once
          .with(:assets)
          .and_call_original

        shotgun_client.assets
        expect(shotgun_client.assets).to be_a(ShotgunApiRuby::Entities)
        expect(shotgun_client.assets.type).to eq('Asset')
        shotgun_client.Asset
      end
    end

    describe 'respond_to_missing' do
      it 'matches everything' do
        expect(shotgun_client.respond_to?(SecureRandom.hex)).to be_truthy
      end
    end
  end
end
