# frozen_string_literal: true

require_relative './fixtures/hibike'

RSpec.describe Lat::MpvScript do
  before(:all) do
    skip unless MPV::Server.available?
    @mpv = MPV::Session.new(user_args: %w[--no-config]).client
    @script = Lat::MpvScript.new(@mpv, sub2srsklass: Lat::Sub2srs::NoOp)
    path = File.expand_path('./blacklist.txt', __dir__)
    Lat::Blacklist.default = Lat::FileBlacklist.new(path)
    path = File.expand_path('./fixtures/hibike.mkv', __dir__)
    loadfile(path: path, options: 'start=71,pause=yes')
    @script.wait_event(:sub_text_changed)
    @script.wait_event(:sub_text_changed)
  end

  after(:all) { @mpv&.command('shutdown') }

  def loadfile(path:, options:)
    f = MPV::Fence.new { |e| e.fetch('event') == 'playback-restart' }
    callback = f.to_proc
    @mpv.callbacks << callback
    @mpv.command('loadfile', path, 'replace', options)
    f.wait
    @mpv.callbacks.delete(callback)
  end

  it 'toggles jplookup on' do
    expect(@script.jplookup_active?).to be false
    @mpv.command(:keypress, 'l')
    @script.wait_event(:jplookup_toggle)
    expect(@script.jplookup_active?).to be true
    expect(@mpv.osd_messages.values.first.text).to eql(
      '駄目 (だめ) no good | not serving its purpose'
    )
  end

  it 'changes jplookup message on sub-seek' do
    @mpv.command('sub-seek', 1)
    @script.wait_event(:sub_text_changed)
    @script.wait_event(:sub_text_changed)
    expect(@mpv.osd_messages.values.first.text).to eql(
      '全国 (ぜんこく) the whole country (P)\\N目指す (めざす) to aim at | to have an eye on'
    )
  end

  it 'exports stuff to anki' do
    @mpv.command(:keypress, 'b')
    @script.wait_event(:enter_modal_mode)
    @mpv.command(:keypress, '1')
    @script.wait_event(:select_modal_option)

    data = @script.sub2srs.data
    expect(data).to eql([HIBIKE1])
  end

  it 'exports stuff to anki [adj]' do
    @mpv.command(:keypress, 'b')
    @script.wait_event(:enter_modal_mode)
    @mpv.command(:keypress, '2')
    @script.wait_event(:select_modal_option)

    data = @script.sub2srs.data
    expect(data).to eql([HIBIKE1, HIBIKE2])
  end

  it 'toggles jplookup off' do
    @mpv.command(:keypress, 'l')
    @script.wait_event(:jplookup_toggle)
    @mpv.command(:keypress, 'l')
    @script.wait_event(:jplookup_toggle)
    expect(@script.jplookup_active?).to be false
    expect(@mpv.osd_messages).to eql({})
  end
end
