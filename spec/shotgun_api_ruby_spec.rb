# frozen_string_literal: true

RSpec.describe ShotgunApiRuby do
  it 'has a version number' do
    expect(ShotgunApiRuby::VERSION).not_to be nil
  end

  it 'creates a client' do
    expect(
      ShotgunApiRuby.new(
        shotgun_site: 'aa',
        auth: { client_id: '', client_secret: '' },
      ),
    ).to be_a ShotgunApiRuby::Client
  end
end
