# typed: false
describe ShotgridApiRuby::ServerInfo, :vcr do
  in_context 'with vcr values' do
    subject(:server_info) { shotgrid_client.server_info }

    it 'exposes the connection' do
      expect(server_info.connection).to be_a Faraday::Connection
    end

    describe 'get server_infos' do
      subject(:server_info_get) { server_info.get }

      it 'parses the server infos from shotgrid' do
        expect(server_info_get.shotgun_version).not_to be_nil
        expect(server_info_get.api_version).not_to be_nil
      end
    end
  end
end
