module Lat
  class MpvScript
    def initialize(mpv)
      @mpv = mpv
      @mpv.observe_property('sub-text', &method(:jplookup_handler))
      @mpv.register_keybindings(
        %w[l GAMEPAD_ACTION_UP],
        section: 'jplookup_toggle',
        &method(:jplookup_toggle)
      )
      @mpv.register_keybindings(%w[u GAMEPAD_ACTION_UP], &method(:sub2srs_n))
    end

    def runloop
      @mpv.runloop
    end

    def sub2srs_n
      @mpv.enter_modal_mode(
        message: 'how many contiguous subs? [1..9]',
        keys: (1..9).to_a.map(&:to_s),
        &method(:sub2srs_n_handler)
      )
    end

    def sub2srs_n_handler(event)
      puts event.inspect
    end

    def jplookup_active?
      @jplookup.present?
    end

    def jplookup_toggle(*)
      @jplookup = !@jplookup
      jplookup_text(@mpv.get_property('sub-text'))
    end

    def jplookup_handler(event)
      jplookup_text(event.data)
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
