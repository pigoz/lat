# frozen_string_literal: true

module Lat
  class Dict
    Result =
      Struct.new(
        :dictionary,
        :lemma,
        :definition,
        :reading,
        :grammar,
        keyword_init: true
      )

    class Result
      def to_repr
        if lemma.chars.any?(&:kanji?)
          [lemma, "(#{reading})", definition].join(' ')
        else
          [lemma, definition].join(' ')
        end
      end

      def to_repr_furigana
        [Furigana.new.call(text: lemma, reading: reading), definition].join(' ')
      end
    end

    def call(lemma:)
      return [] unless japanese?(lemma)

      results = `myougiden --color=no -t #{lemma}`.strip.split("\n")
      results.map { |result| build_result(result, lemma) }
    end

    private

    def japanese?(lemma)
      l = lemma.chars
      %i[kanji? hiragana? katakana?].map { |m| l.any?(&m) }.any?
    end

    def build_result(result, lemma)
      parts = result.split("\t")
      d = parse_definition(parts.third)
      Lat::Dict::Result.new(
        dictionary: 'myougiden',
        lemma: first_item(parts.second) || lemma,
        grammar: d.fetch('grammar'),
        definition: d.fetch('definition').split('|').take(2).join(' | '),
        reading: first_item(parts.first)
      )
    end

    def first_item(csvstring)
      csvstring.split('；').first
    end

    def parse_definition(definition)
      regexp = /\[(?<grammar>.+)\]\s(?<definition>.+)/
      regexp.match(definition).named_captures
    end
  end
end
