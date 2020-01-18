RSpec.describe Lat do
  it 'does something useful' do
    mpv = MPV::Session.new
    expect(mpv.get_property(:volume)).to eql(100.0)
  end
end
