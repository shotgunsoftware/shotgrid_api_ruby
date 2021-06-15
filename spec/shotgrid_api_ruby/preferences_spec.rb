describe ShotgridApiRuby::Preferences, :vcr do
  in_context 'with vcr values' do
    subject(:preferences) { shotgrid_client.preferences }

    it 'exposes the connection' do
      expect(preferences.connection).to be_a Faraday::Connection
    end

    describe 'all preferences' do
      subject(:preferences_all) { preferences.all }

      it 'parses the preferences from shotgrid' do
        expect(preferences_all.support_local_storage).not_to be_nil
      end
    end
  end
end
