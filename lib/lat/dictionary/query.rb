# frozen_string_literal: true

require 'sequel'
require 'sequel/extensions/migration'

module Lat
  module Dictionary
    class Query
      def self.db
        @db ||= begin
          x = Sequel.sqlite(Lat.tmp_path('dictionary.sqlite'))
          dir = File.expand_path('migrations', __dir__)
          Sequel::Migrator.run(x, dir)
          x
        end
      end

      Result =
        Struct.new(
          :dictionary,
          :lemma,
          :definition,
          :reading,
          :grammar,
          keyword_init: true
        )

      def scope
        db = self.class.db
        db[:entries].join_table(:inner, db[:lemmas].as(:l), entry_id: :id)
      end

      def count
        scope.count
      end

      def call(lemma:)
        return [] unless japanese?(lemma)

        scope.where(lemma: lemma).all.map do |x|
          Lat::Dictionary::Result.new(
            dictionary: x[:dictionary],
            lemma: x[:lemma],
            grammar: JSON.parse(x[:pos]).map { |y| clean_gammar_field(y) },
            definition: JSON.parse(x[:gloss]),
            reading: JSON.parse(x[:reading])
          )
        end
      end

      def clean_gammar_field(grammar)
        grammar.sub(/\s*\(.+\)$/, '')
      end

      def japanese?(lemma)
        l = lemma.chars
        %i[kanji? hiragana? katakana?].map { |m| l.any?(&m) }.any?
      end
    end
  end
end
