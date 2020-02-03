# frozen_string_literal: true

RSpec.describe Lat do
  before(:all) do
    skip unless MPV::Server.available?
    @mpv = Lat::Mpv.test_instance
  end

  before(:each) do
    path = File.expand_path('./fixtures/hibike.mkv', __dir__)
    @mpv.loadfile(path: path, options: 'start=71,pause=yes')
  end

  after(:all) { @mpv&.quit! }

  it 'can observe properties' do
    args = []
    block = proc { |a| args << a }
    @mpv.wait('property-change') { @mpv.observe_property(:volume, &block) }
    @mpv.wait('property-change') { @mpv.set_property(:volume, 10) }
    expect(args.map(&:data)).to eql([100.0, 10.0])
  end

  it 'calls into mpv' do
    expect(@mpv.get_property(:"sub-text")).to eql(
      '何でみんなダメ金なんかで喜べるの'
    )
  end
end
