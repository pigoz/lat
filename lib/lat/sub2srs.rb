# frozen_string_literal: true

module Lat
  class Sub2srs
    Data = S.new(:text, :title, :sub_start, :sub_end, :apath, :aid)

    attr_reader :data

    def initialize(data)
      @data = data
    end

    def call
      Anki.new(card_data).call
    end

    Timing = Struct.new(:st, :ed)

    def card_data
      first = data.first
      line = data.map(&:text).join
      lexer = Lat::Lexer.new
      lexer_results = lexer.call(line)
      definitions = lexer.to_definitions(lexer_results)
      timings = data.map { |x| Timing.new(x[:sub_start], x[:sub_end]) }
      ffmpeg = Ffmpeg.new(path: first.apath, timings: timings)

      Anki::CardData.new(
        line: line || '',
        reading: lexer.to_text(lexer_results),
        sound: ffmpeg.audio_sample(aid: first.aid),
        image: ffmpeg.screenshot,
        words: definitions.map(&:to_repr_furigana),
        source: first.title,
        time: first.sub_start.to_s
      )
    end

    class NoOp < Sub2srs
      def call; end
    end
  end
end
