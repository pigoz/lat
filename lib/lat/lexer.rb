# frozen_string_literal: true

module Lat
  class Lexer
    attr_accessor :charset
    attr_reader :mecab

    def to_text(results)
      results.map(&:to_text).join
    end

    def initialize
      @mecab = Natto::MeCab.new(mecab_options)
      @charset = detect_charset
    end

    def call(text)
      @mecab.enum_parse(text).to_a.map { |r| parse_result(r) }
    end

    def decode(string)
      return string if charset == 'utf-8'

      require 'iconv'
      string = string.dup.force_encoding(charset)
      Iconv.conv('utf-8', charset, string)
    end

    private

    KEYS = %i[g1 g2 x1 x2 x3 x4 lemma reading1 reading2].freeze

    Result = S.new(*KEYS, :surface, :surface_len, :surface_rlen)

    class Result
      QUERIES = {
        noun: %w[名詞],
        verb: %w[動詞],
        particle: %w[助詞],
        punctuation: %w[記号],
        eos: %w[BOS/EOS]
      }.freeze

      QUERIES.each do |k, v|
        define_method :"#{k}?" do
          g1 == v.first
        end
      end

      def grammar
        QUERIES.each { |x, _| return x if public_send(:"#{x}?") }
        g1.intern
      end

      def reading
        (reading1 || reading2)&.hiragana
      end

      def leading_whitespace
        ' ' * (surface_rlen - surface_len)
      end

      def surface_with_furigana
        if Blacklist.default.blacklisted?(lemma)
          surface
        else
          Lat::Furigana.new.call(text: surface, reading: reading)
        end
      end

      def to_text
        "#{leading_whitespace}#{surface_with_furigana}"
      end
    end

    def detect_charset
      charsets = mecab.dicts.map(&:charset).uniq
      Lat.assert('single mecab encoding') { charsets.size == 1 }
      charset = charsets.first
      (charset == 'utf8' ? 'utf-8' : charset).downcase
    end

    def mecab_options
      dic = ENV.fetch('MECAB_DICTIONARY')
      { dicdir: "/usr/local/lib/mecab/dic/#{dic}/" }
    rescue StandardError
      {}
    end

    def parse_result(result)
      split = decode(result.feature).split(',')
      split = split.map { |x| x == '*' ? nil : x }
      feature = Hash[KEYS.zip(split.flatten)]
      surface = {
        surface: decode(result.surface),
        surface_len: result.length,
        surface_rlen: result.rlength
      }
      Result.new(feature.merge(surface))
    end
  end
end
