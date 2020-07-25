# frozen_string_literal: true

module Lat
  class Database
    ANKI_DATABASE = Lat::Anki.user_file_path('collection.anki2')
    ANKI_DECKS = { 'sub2srs' => 4, '例文' => 1 }.freeze

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
      decks = Hash[decks_data]

      anki[:cards]
        .where(did: decks.keys)
        .join_table(:inner, anki[:notes].as(:note), id: :nid)
        .map { |card| load_card(decks, card) }
    end

    def load_card(decks, card)
      field_idx = decks[card[:did]]
      text = card[:flds].split("\u{1f}")[field_idx]
      text.gsub(/\[.*\]/, '')
    end

    def decks_data
      # XXX should use models instead of decks
      xs = JSON.parse(anki[:col].first[:decks]).values
      xs.select { |x| x['name'].in?(ANKI_DECKS) }
        .map { |x| [x['id'], ANKI_DECKS[x['name']]] }
    end

    def anki
      @anki ||= Sequel.sqlite(ANKI_DATABASE, readonly: true)
    end
  end
end
