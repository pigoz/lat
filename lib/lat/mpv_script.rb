# frozen_string_literal: true

module Lat
  class MpvScript
    attr_reader :sub2srs

    EVENTS = %i[
      jplookup_toggle
      enter_modal_mode
      export_done
      sub_text_changed
    ].freeze

    def initialize(mpv, sub2srsklass: Sub2srs)
      @mpv = mpv
      @fence = MPV::Fence.new
      @sub2srsklass = sub2srsklass
      @mpv.observe_property('sub-text', &method(:sub_text_changed))
      @mpv.register_keybindings(
        %w[l GAMEPAD_ACTION_UP],
        section: 'jplookup_toggle',
        &method(:jplookup_toggle)
      )
      @mpv.register_keybindings(%w[b], &method(:sub2srs_n))
      @mpv.register_keybindings(%w[g]) { sub2srs_n_handler_int(1) }
    end

    def dispatch(event)
      @fence.to_proc.call(event)
    end

    def wait_event(event)
      # @fence.wait_until { |x| }
      loop do
        x = @fence.wait1.first
        break if event == x
      end
    end

    def join
      @mpv.join
    end

    def sub_text_changed(event)
      @subs&.push(event.data) if event.data.present?
      jplookup_text(event.data) if jplookup_active?
      dispatch(:sub_text_changed)
    end

    def sub2srs_n(event)
      return unless event.keydown?

      jplookup_off
      @mpv.enter_modal_mode(
        'how many contiguous subs? [1..9]',
        (1..9).to_a.map(&:to_s),
        &method(:sub2srs_n_handler)
      )

      dispatch(:enter_modal_mode)
    end

    def sub2srs_n_handler(event)
      return unless event.keydown?

      count = event.key.to_i
      sub2srs_n_handler_int(count)
    end

    def sub2srs_n_handler_int(count)
      @subs = Queue.new
      data =
        (0...count).to_a.reverse.map do |idx|
          el = build_sub_data
          if idx.positive?
            @mpv.command('sub-seek', 1)
            @subs.pop
          end
          el
        end

      msgid = @mpv.create_osd_message('exporting to anki')

      @sub2srs = @sub2srsklass.new(data)
      ok, line = @sub2srs.call

      if ok
        @mpv.edit_osd_message(msgid, "exported: #{line}", timeout: 1)
      else
        @mpv.edit_osd_message(msgid, "error exporting: #{line}")
      end

      dispatch(:export_done)
    end

    def build_sub_data
      delay = @mpv.get_property('sub-delay').data
      Sub2srs::Data.new(
        apath: @mpv.get_property('path').data,
        aid: @mpv.get_property('aid').data,
        title: @mpv.get_property('media-title').data,
        text: @mpv.get_property('sub-text').data,
        sub_start: @mpv.get_property('sub-start').data + delay.to_f,
        sub_end: @mpv.get_property('sub-end').data + delay.to_f
      )
    end

    def jplookup_active?
      @jplookup.present?
    end

    def jplookup_off
      @jplookup = false
      @mpv.clear_osd_messages
    end

    def jplookup_toggle(event)
      return unless event.keydown?

      @jplookup = !@jplookup

      if jplookup_active?
        jplookup_text(@mpv.get_property('sub-text').data)
      else
        @mpv.clear_osd_messages
      end

      dispatch(:jplookup_toggle)
    end

    def jplookup_text(text)
      if text.present?
        lexer = Lat::Lexer.new
        lexer_results = lexer.call(text)
        defs = lexer.to_definitions(lexer_results)
        @mpv.create_osd_message(defs.map(&:to_repr).join('\\N'))
      else
        @mpv.clear_osd_messages
      end
    end
  end
end
