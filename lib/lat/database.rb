# frozen_string_literal: true

module Lat
  class Database
    ANKI_DATABASE = Lat::Anki.user_file_path('collection.anki2')
    ANKI_NOTE_TYPES = Settings.anki.morphemes_fields.to_h.stringify_keys

    def morphemes
      require 'parallel'
      morphemes_for(load_cards)
    end

    def morphemes_for(sentences)
      mecab = Lat::Lexer.new
      lex = ->(text) { mecab.call(text).map(&:surface) }
      Parallel.flat_map(Array(sentences), &lex).uniq
    end

    def load_cards
      require 'sequel'
      fields = Hash[fields_map]

      anki[:cards]
        .join_table(:inner, anki[:notes].as(:note), id: :nid)
        .where(mid: fields.keys)
        .map { |card| load_card(fields, card) }
    end

    def load_card(fields, card)
      field_idx = fields[card[:mid]][:ord]
      text = card[:flds].split("\u{1f}")[field_idx]
      text.gsub(/\[.*\]/, '')
    end

    def models_data
      models_json = anki[:col].first[:models]
      xs = JSON.parse(models_json, symbolize_names: true).values
      xs.select { |x| x[:name].in?(ANKI_NOTE_TYPES.keys) }
    end

    def fields_map
      models_data.map do |x|
        field_name = ANKI_NOTE_TYPES[x[:name]]
        [x[:id], x[:flds].select { |f| f[:name] == field_name }.first]
      end
    end

    def anki
      @anki ||= Sequel.sqlite(ANKI_DATABASE, readonly: true)
    end
  end
end
