# frozen_string_literal: true

module Lat
  class Dict
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
      Lat::Dictionary::Result.new(
        dictionary: 'myougiden',
        lemma: first_item(parts.second) || lemma,
        grammar: d.fetch('grammar').split(','),
        definition: d.fetch('definition').split('|').take(2),
        reading: Array(first_item(parts.first))
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
