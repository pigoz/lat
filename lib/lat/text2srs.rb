# frozen_string_literal: true

module Lat
  class Text2srs
    def initialize(text, source, sound: nil, image: nil)
      @text = text
      @source = source
      @sound = sound
      @image = image
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
      sound = @sound || Tts.new(@text).call
      image = @image || nil

      Anki::CardData.new(
        line: @text,
        reading: lexer.to_text(lexer_results),
        sound: sound,
        image: image,
        words: definitions.map(&:to_repr_furigana),
        source: @source
      )
    end
  end
end
