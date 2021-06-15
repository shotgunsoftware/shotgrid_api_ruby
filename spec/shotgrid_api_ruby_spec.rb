# frozen_string_literal: true

RSpec.describe ShotgridApiRuby do
  it 'has a version number' do
    expect(ShotgridApiRuby::VERSION).not_to be nil
  end

  it 'creates a client' do
    expect(
      ShotgridApiRuby.new(
        shotgrid_site: 'aa',
        auth: {
          client_id: '',
          client_secret: '',
        },
      ),
    ).to be_a ShotgridApiRuby::Client
  end
end
