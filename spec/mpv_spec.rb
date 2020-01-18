RSpec.describe Lat do
  xit 'calls into mpv' do
    mpv = MPV::Session.new
    expect(mpv.get_property(:volume)).to eql(100.0)
  end
end
