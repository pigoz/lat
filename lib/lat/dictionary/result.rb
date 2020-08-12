# frozen_string_literal: true

module Lat
  module Dictionary
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
      def definition_repr
        definition.take(3).join(' | ')
      end

      def reading_repr
        reading.first
      end

      def repr_from_parts(*parts)
        parts.join(' ')
      end

      def to_repr
        if lemma.chars.any?(&:kanji?)
          repr_from_parts(lemma, "(#{reading_repr})", definition_repr)
        else
          repr_from_parts(lemma, definition_repr)
        end
      end

      def to_repr_furigana
        furigana = Furigana.new.call(text: lemma, reading: reading_repr)
        repr_from_parts(furigana, definition_repr)
      end
    end
  end
end
