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

  def later(&block)
    Thread.new { block.call }
  end

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
    later { @mpv.command('script-message', m) }
    fence.wait
    expect(calls).to eql(1)

    later { @mpv.command('script-message', m) }
    fence.wait
    expect(calls).to eql(2)
  end

  it 'can register a binding' do
    args = []
    block = proc { |a| args << a }
    fence = @mpv.fence('client-message')
    section = @mpv.register_keybindings(%w[b c d], &block)
    later { @mpv.command('keypress', 'g') }
    later { @mpv.command('keypress', 'c') }
    fence.wait
    expect(args.map(&:key)).to eql(%w[c])

    @mpv.unregister_keybindings(section)
    later { @mpv.command('keypress', 'b') }
    fence.wait
    expect(args.map(&:key)).to eql(%w[c])
  end

  it 'can get client_name' do
    expect(@mpv.client_name).to match('ipc_')
  end

  it 'calls into mpv' do
    expect(@mpv.get_property(:"sub-text")).to eql(
      '何でみんなダメ金なんかで喜べるの'
    )
  end

  it 'can release runloop lock' do
    mpv = Lat::Mpv.test_instance
    later { mpv.quit! }
    mpv.runloop
  end
end
