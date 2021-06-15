# frozen_string_literal: true

RSpec.define_context 'with vcr values', ns: 'vcr' do
  # Try to read env variables or take a "sensitive default"
  # Those values will be [REDACTED] in vcr cassettes and will always match
  let(:shotgun_site_name) { 'pasind3-prod' }
  let(:shotgun_site_url) { 'https://pasind3-prod.shotgunstudio.com/api/v1' }
  let(:shotgun_client_id) do
    ENV['VCR_SHOTGUN_SCRIPT_NAME'] || 'vcr_shotgun_script_name'
  end

  let(:shotgun_client_secret) do
    ENV['VCR_SHOTGUN_SCRIPT_KEY'] || 'vcr_shotgun_script_key'
  end

  let(:shotgun_username) do
    ENV['VCR_SHOTGUN_USERNAME'] || 'vcr_shotgun_username'
  end

  let(:shotgun_password) do
    ENV['VCR_SHOTGUN_PASSWORD'] || 'vcr_shotgun_password'
  end

  let(:shotgun_client) do
    ShotgunApiRuby.new(
      shotgun_site: shotgun_site_name,
      auth: {
        client_id: shotgun_client_id,
        client_secret: shotgun_client_secret,
      },
    )
  end

  execute_tests
end
