module Lat
  class MpvScript
    def initialize(mpv)
      @mpv = mpv
    end

    def run
      @mpv.observe_property('sub-text', &method(:sub_text_changed))
      @mpv.runloop
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
