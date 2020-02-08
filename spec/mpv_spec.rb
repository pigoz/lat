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
    spy = Lat::Spy.new
    @mpv.observe_property(:volume, &spy)
    @mpv.set_property(:volume, 10)
    result = spy.wait(runs: 1)
    expect(result.map(&:first).map(&:data)).to eql([10.0])
  end

  it 'can handle client-messages' do
    spy = Lat::Spy.new
    m = 'lat/test_message'
    @mpv.register_message_handler(m, &spy)
    @mpv.command('script-message', m, 'a', 'b')
    @mpv.command('script-message', m, 'c', 'd')
    result = spy.wait(runs: 2)
    expect(result).to eql([%w[a b], %w[c d]])
  end

  it 'can register a binding' do
    spy = Lat::Spy.new
    section = @mpv.register_keybindings(%w[b c d], &spy)
    @mpv.command('keypress', 'g')
    @mpv.command('keypress', 'c')
    expect(spy.wait.map(&:first).map(&:key)).to eql(%w[c])

    @mpv.unregister_keybindings(section)
    @mpv.command('keypress', 'b')
    expect(spy.runs(timeout: 1)).to eql(1)
  end

  it 'can get client_name' do
    expect(@mpv.client_name).to match('ipc_')
  end

  it 'can release runloop lock' do
    mpv = Lat::Mpv.test_instance
    Thread.new { mpv.quit! }
    mpv.runloop
  end
end
