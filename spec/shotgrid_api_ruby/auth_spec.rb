describe ShotgridApiRuby::Auth, :vcr do
  describe ShotgridApiRuby::Auth::Validator do
    it 'accepts client_id and client_secret' do
      expect(
        described_class.valid?(client_id: 'aa', client_secret: 'ss'),
      ).to be_truthy
      expect(described_class.valid?(client_secret: 'ss')).to be_falsy
      expect(described_class.valid?(client_id: 'aa')).to be_falsy
    end

    it 'accepts username and password' do
      expect(
        described_class.valid?(username: 'aa', password: 'ss'),
      ).to be_truthy
      expect(described_class.valid?(username: 'ss')).to be_falsy
      expect(described_class.valid?(password: 'aa')).to be_falsy
    end

    it 'accepts session_token' do
      expect(described_class.valid?(session_token: 'aa')).to be_truthy
    end

    it 'accepts refresh_token' do
      expect(described_class.valid?(refresh_token: 'aa')).to be_truthy
    end
  end

  in_context 'with vcr values' do
    context 'with client_id and client_secret' do
      it 'connects' do
        client =
          ShotgridApiRuby.new(
            shotgun_site: shotgun_site_name,
            auth: {
              client_id: shotgun_client_id,
              client_secret: shotgun_client_secret,
            },
          )
        expect(client.server_info.get.shotgun_version).not_to be_nil
        client =
          ShotgridApiRuby.new(
            shotgrid_site: shotgrid_site_name,
            auth: {
              client_id: shotgrid_client_id,
              client_secret: shotgrid_client_secret,
            },
          )
        expect(client.server_info.get.shotgun_version).not_to be_nil
      end
    end

    context 'with username and password' do
      it 'connects' do
        client =
          ShotgridApiRuby.new(
            shotgun_site: shotgun_site_name,
            auth: {
              username: shotgun_username,
              password: shotgun_password,
            },
          )
        expect(client.server_info.get.shotgun_version).not_to be_nil
      end
    end

    context 'with refresh_token' do
      it 'is difficult to test…'
    end

    context 'with session_token' do
      it 'is difficult to test…'
    end
  end
end
