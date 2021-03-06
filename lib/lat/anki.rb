# frozen_string_literal: true

module Lat
  class Anki
    # CardData
    def initialize(data)
      @data = data
    end

    def self.user_file_path(file)
      File.join(
        Lat.expand_settings_path(Settings.anki.collection),
        file
      )
    end

    ANKI_MEDIA_COLLECTION = user_file_path('collection.media')
    ANKI_DECK_NAME = Settings.anki.export.deck_name
    ANKI_NOTE_TYPE = Settings.anki.export.note_type
    ANKI_TAG_NAME = Settings.anki.export.tag_name

    def call
      ankiapi('changeDeck', cards: [], deck: ANKI_DECK_NAME)
      res =
        ankiapi(
          'addNote',
          note: {
            deckName: ANKI_DECK_NAME,
            modelName: ANKI_NOTE_TYPE,
            fields: @data.to_params,
            tags: [ANKI_TAG_NAME]
          }
        )
      ok = res.code == 200
      @data.stage_media if ok
      [ok, @data.line]
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
        f = Settings.anki.fields
        result = {
          f.source => source,
          f.line => line,
          f.reading => reading,
          f.words => words.join('<br>'),
          f.time => time,
          f.sound => sound ? "[sound:#{File.basename(sound)}]" : nil,
          f.image => image ? "<img src=#{File.basename(image)}>" : nil
        }
        result.compact.except(nil)
      end

      def stage_media
        require 'fileutils'

        if sound
          FileUtils.cp(
            sound,
            File.join(ANKI_MEDIA_COLLECTION, File.basename(sound))
          )
        end

        if image
          FileUtils.cp(
            image,
            File.join(ANKI_MEDIA_COLLECTION, File.basename(image))
          )
        end
      end
    end
  end
end
