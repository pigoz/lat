module Lat
  class Sub2srs
    Data = S.new(:text, :title, :sub_start, :sub_end, :apath, :aid)

    attr_reader :data

    def initialize(data)
      @data = data
    end

    ANKI_MEDIA_COLLECTION =
      File.expand_path(
        '~/Library/Application Support/Anki2/User 1/collection.media'
      )
    ANKI_DECK_NAME = 'sub2srs'.freeze
    ANKI_NOTE_TYPE = 'Japanese sub2srs'.freeze
    ANKI_TAG_NAME = 'sub2srs'.freeze

    def call
      cd = card_data
      ankiapi('changeDeck', cards: [], deck: ANKI_DECK_NAME)
      res =
        ankiapi(
          'addNote',
          note: {
            deckName: ANKI_DECK_NAME,
            modelName: ANKI_NOTE_TYPE,
            fields: cd.to_params,
            tags: [ANKI_TAG_NAME]
          }
        )
      ok = res.code == 200
      cd.stage_media if ok
      [ok, cd.line]
    end

    def ankiapi(method, params)
      require 'rest-client'
      hostname = 'http://127.0.0.1:8765'
      data = { action: method, version: 6, params: params }
      headers = { content_type: :json, accept: :json }
      RestClient.post(hostname, data.to_json, headers)
    end

    CardData = S.new(:source, :time, :sound, :image, :line, :reading, :words)

    class CardData
      def to_params
        {
          Source: source,
          Time: time,
          Line: line,
          Reading: reading,
          Sound: "[sound:#{File.basename(sound)}]",
          Image: "<img src=#{File.basename(image)}>",
          Words: words.join('<br>')
        }
      end

      def stage_media
        require 'fileutils'
        FileUtils.cp(
          sound,
          File.join(ANKI_MEDIA_COLLECTION, File.basename(sound))
        )
        FileUtils.cp(
          image,
          File.join(ANKI_MEDIA_COLLECTION, File.basename(image))
        )
      end
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
      CardData.new(
        line: line,
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
