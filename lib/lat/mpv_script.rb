module Lat
  class MpvScript
    attr_reader :sub2srs

    def initialize(mpv, sub2srsklass: Sub2srs)
      @mpv = mpv
      @spy = Spy.new
      @sub2srsklass = sub2srsklass
      @mpv.observe_property('sub-text', &method(:sub_text_changed))
      @mpv.register_keybindings(
        %w[l GAMEPAD_ACTION_UP],
        section: 'jplookup_toggle',
        &method(:jplookup_toggle)
      )
      @mpv.register_keybindings(%w[b GAMEPAD_ACTION_UP], &method(:sub2srs_n))
    end

    def runloop
      @mpv.runloop
    end

    def sub_text_changed(event)
      jplookup_text(event.data)
      @spy.notify(event)
    end

    def sub2srs_n(*)
      jplookup_off
      @mpv.enter_modal_mode(
        message: 'how many contiguous subs? [1..9]',
        keys: (1..9).to_a.map(&:to_s),
        &method(:sub2srs_n_handler)
      )
    end

    def sub2srs_n_handler(event)
      count = event.key.to_i
      data =
        (0...count).to_a.reverse.map do |idx|
          el = build_sub_data
          seek_and_wait_sub_text if idx.positive?
          el
        end

      @sub2srs = @sub2srsklass.new(data)
      @sub2srs.call
    end

    def build_sub_data
      Sub2srs::Data.new(
        apath: @mpv.get_property('path'),
        aid: @mpv.get_property('aid'),
        title: @mpv.get_property('media-title'),
        text: @mpv.get_property('sub-text'),
        start: @mpv.get_property('sub-start'),
        end: @mpv.get_property('sub-end')
      )
    end

    def seek_and_wait_sub_text
      @spy.clear!
      @mpv.command('sub-seek', 1)
      @spy.wait(runs: 2, clear: true)
    end

    def jplookup_active?
      @jplookup.present?
    end

    def jplookup_off
      @jplookup = false
      @mpv.clear_message
    end

    def jplookup_toggle(*)
      @jplookup = !@jplookup
      jplookup_text(@mpv.get_property('sub-text'))
    end

    def jplookup_text(text)
      if text.present? && jplookup_active?
        lexer = Lat::Lexer.new
        lexer_results = lexer.call(text)
        defs = lexer.to_definitions(lexer_results)
        @mpv.message(defs.map(&:to_repr).join('\\N'))
      else
        @mpv.clear_message
      end
    end
  end
end
