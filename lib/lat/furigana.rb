# frozen_string_literal: true

require 'natto'
require 'mojinizer'
require 'diff-lcs'

module Lat
  class Furigana
    def call(text:, reading:)
      return text unless text.present? && reading.present?

      best = guesses(text, reading).min_by(&:score)
      current = 0
      text.chars.zip(best.lreadings).map do |t, r|
        start = current.dup
        current += r.size
        args = { char: t, reading: r, start: start, lcs: best.lcs }
        CharWithReading.new(**args)
      end.join
    end

    class RG < S.new(:lreadings, :lcs)
      def score
        [
          lcs.select(&:changed?).size,
          lcs.select(&:adding?).size * 3,
          lcs.select(&:deleting?).size * 3
        ].sum
      end
    end

    def guesses(text, reading)
      chars = text.chars
      xs = chars.map { |c| lookup_guesses_for(c) }.cartesian
      xs.map do |guess|
        RG.new(lreadings: guess, lcs: Diff::LCS.sdiff(guess.join, reading))
      end
    end

    def lookup_guesses_for(letter)
      readings = database[letter]
      return Array(letter) if readings.nil? # probably hiragana or katakana

      readings.map { |x| x.split('.').first.hiragana }
    end

    def database
      JSON.parse(IO.read(database_path))
    end

    def database_path
      File.expand_path('./kanjidb.json', __dir__)
    end
  end

  class CharWithReading < S.new(:char, :reading, :start, :lcs)
    def change_operations
      lcs.select(&:changed?).select do |operation|
        rend = start + reading.size
        (start...rend).include?(operation.new_position)
      end
    end

    def modified_reading
      change_operations.each_with_object(reading.dup) do |operation, r|
        r[operation.new_position - start] = operation.new_element
      end
    end

    def to_s
      char.kanji? ? " #{char}[#{modified_reading}]" : char
    end
  end
end
