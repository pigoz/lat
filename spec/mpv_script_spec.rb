# frozen_string_literal: true

RSpec.describe Lat::MpvScript do
  before(:all) do
    skip unless MPV::Server.available?
    @spy = Lat::Spy.new
    @mpv = Lat::Mpv.test_instance(spy: @spy)
    @script = Lat::MpvScript.new(@mpv)
    path = File.expand_path('./blacklist.txt', __dir__)
    Lat::Blacklist.default = Lat::FileBlacklist.new(path)
    path = File.expand_path('./fixtures/hibike.mkv', __dir__)
    @mpv.loadfile(path: path, options: 'start=71,pause=yes')
    wait_observe_property('sub-text')
  end

  def wait_observe_property(name)
    events = @spy.wait(runs: 2, clear: true)
    expect(events.map { |e| e.second.property }).to eql([name, name])
  end

  def wait_keydown(key)
    events = @spy.wait(runs: 1, clear: true)
    expect(events.first.second.key).to eql(key)
  end

  after(:all) { @mpv&.quit! }

  it 'toggles jplookup on' do
    expect(@script.jplookup_active?).to be false
    @mpv.command(:keypress, 'l')
    wait_keydown('l')
    expect(@script.jplookup_active?).to be true
    expect(@mpv.overlay.message).to eql(
      '駄目 (だめ) - no good|not serving its purpose|useless|broken'
    )
  end

  it 'changes jplookup message on sub-seek' do
    @mpv.command('sub-seek', 1)
    wait_observe_property('sub-text')
    expect(@mpv.overlay.message).to eql(
      '全国 (ぜんこく) - the whole country (P)\\N目指す (めざす) - to aim at|to have an eye on'
    )
  end

  it 'toggles jplookup off' do
    @mpv.command(:keypress, 'l')
    wait_keydown('l')
    expect(@script.jplookup_active?).to be false
    expect(@mpv.overlay).to eql(nil)
  end
end
