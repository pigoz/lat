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

  class Spy
    def initialize
      @mutex = Mutex.new
      @resource = ConditionVariable.new
      clear
    end

    def clear
      @queue = []
      @runs = 0
    end

    def to_proc
      proc do |*args|
        @mutex.synchronize do
          @queue << args
          @runs += 1
          @resource.signal
        end
      end
    end

    DEFAULT_TIMEOUT = 0.3

    def wait(runs: 1, timeout: DEFAULT_TIMEOUT)
      @mutex.synchronize do
        (runs - @runs).times { @resource.wait(@mutex, timeout) }
      end
      @queue
    end

    def runs(timeout: DEFAULT_TIMEOUT)
      @mutex.synchronize { @resource.wait(@mutex, timeout) }
      @runs
    end
  end

  it 'can observe properties' do
    spy = Spy.new
    @mpv.observe_property(:volume, &spy)
    @mpv.set_property(:volume, 10)
    result = spy.wait(runs: 2)
    expect(result.map(&:first).map(&:data)).to eql([100.0, 10.0])
  end

  it 'can handle client-messages' do
    spy = Spy.new
    m = 'lat/test_message'
    @mpv.register_message_handler(m, &spy)
    @mpv.command('script-message', m, 'a', 'b')
    @mpv.command('script-message', m, 'c', 'd')
    result = spy.wait(runs: 2)
    expect(result).to eql([%w[a b], %w[c d]])
  end

  it 'can register a binding' do
    spy = Spy.new
    section = @mpv.register_keybindings(%w[b c d], &spy)
    @mpv.command('keypress', 'g')
    @mpv.command('keypress', 'c')
    expect(spy.wait.map(&:first).map(&:key)).to eql(%w[c])

    @mpv.unregister_keybindings(section)
    @mpv.command('keypress', 'b')
    expect(spy.runs).to eql(1)
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
    Thread.new { mpv.quit! }
    mpv.runloop
  end
end
