describe ShotgridApiRuby::ShotgridCallError do
  let(:message) { Faker::Movies::PrincessBride.quote }
  let(:response) do
    double('response', status: Random.rand(200..600), message: message)
  end

  it 'contains a message' do
    begin
      raise described_class.new(response: response, message: message)
    rescue => e
      expect(e).to be_a ShotgridApiRuby::ShotgridCallError
      expect(e.message).to eq(message)
    end
  end

  it 'is catched as StandardError' do
    begin
      raise described_class.new(response: response, message: message)
    rescue StandardError => e
      expect(e).to be_a ShotgridApiRuby::ShotgridCallError
    end
  end

  it 'gives access to the response' do
    begin
      raise described_class.new(response: response, message: message)
    rescue => e
      expect(e).to be_a ShotgridApiRuby::ShotgridCallError
      expect(e.response.message).to eq(message)
    end
  end

  it 'forward status to the response object' do
    begin
      raise described_class.new(response: response, message: message)
    rescue => e
      expect(e).to be_a ShotgridApiRuby::ShotgridCallError
      expect(e.status).to eq(response.status)
    end
  end
end
