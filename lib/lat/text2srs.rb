# frozen_string_literal: true

module Lat
  class Text2srs
    def initialize(text, source)
      @text = text
      @source = source
    end

    def call
      data = card_data
      puts data
      Anki.new(data).call
    end

    def card_data
      lexer = Lat::Lexer.new
      lexer_results = lexer.call(@text)
      definitions = lexer.to_definitions(lexer_results)
      sound = Tts.new(@text).call

      Anki::CardData.new(
        line: @text,
        reading: lexer.to_text(lexer_results),
        sound: sound,
        words: definitions.map(&:to_repr_furigana),
        source: @source
      )
    end
  end
end
