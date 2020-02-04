# frozen_string_literal: true

RSpec.describe Lat::Mpv do
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
    fence = @mpv.fence('property-change')
    @mpv.observe_property(:volume, &block)
    @mpv.set_property(:volume, 10)
    fence.wait
    expect(args.map(&:data)).to eql([100.0, 10.0])
  end

  it 'can handle client-messages' do
    calls = 0
    block = proc { calls += 1 }
    m = 'lat/test_message'

    fence = @mpv.fence('client-message')
    @mpv.register_message_handler(m, &block)
    @mpv.command('script-message', m)
    fence.wait
    expect(calls).to eql(1)

    @mpv.command('script-message', m)
    fence.wait
    expect(calls).to eql(2)
  end

  it 'calls into mpv' do
    expect(@mpv.get_property(:"sub-text")).to eql(
      '何でみんなダメ金なんかで喜べるの'
    )
  end
end
