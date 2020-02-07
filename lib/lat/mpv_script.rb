module Lat
  class MpvScript
    def initialize(mpv)
      @mpv = mpv
    end

    def run
      # @mpv.observe_property('sub-text', &method(:sub_text_changed))
      @mpv.enter_modal_mode(
        message: 'how many contiguous subs? [1..9]',
        keys: (1..9).to_a.map(&:to_s),
        &method(:modal_handler)
      )
      @mpv.runloop
    end

    def modal_handler(event)
      puts event.inspect
    end

    def sub_text_changed(event)
      text = event.data
      if text.present?
        lexer = Lat::Lexer.new
        lexer_results = lexer.call(text)
        defs = lexer.to_definitions(lexer_results)
        @mpv.message(defs.map(&method(:def_repr)).join('\\N'))
      else
        @mpv.clear_message
      end
    end

    def def_repr(definition)
      "#{definition.lemma} (#{definition.reading}) - #{definition.definition}"
    end
  end
end
