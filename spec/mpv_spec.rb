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

  it 'can handle client-messages' do
    calls = 0
    block = proc { calls += 1 }
    e = 'client-message'
    m = 'lat/test_message'

    @mpv.register_message_handler(m, &block)
    @mpv.wait(e) { @mpv.command('script-message', m) }
    expect(calls).to eql(1)
    @mpv.wait(e) { @mpv.command('script-message', m) }
    expect(calls).to eql(2)
  end

  it 'calls into mpv' do
    expect(@mpv.get_property(:"sub-text")).to eql(
      '何でみんなダメ金なんかで喜べるの'
    )
  end
end
