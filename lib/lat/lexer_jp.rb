# frozen_string_literal: true

require 'mojinizer'
require 'natto'

module Lat
  class LexerJp
    attr_accessor :charset
    attr_reader :mecab

    def initialize
      @mecab = Natto::MeCab.new(mecab_options)
      @charset = detect_charset
    end

    def call(text)
      @mecab.enum_parse(text).to_a.map { |r| parse_result(r) }
    end

    KEYS = %i[g1 g2 x1 x2 x3 x4 lemma reading1 reading2].freeze

    Result = Struct.new(*KEYS, :text, keyword_init: true)

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
    end

    def decode(string)
      return string if charset == 'utf-8'

      require 'iconv'
      string = string.dup.force_encoding(charset)
      Iconv.conv('utf-8', charset, string)
    end

    private

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
      Result.new(feature.merge(text: decode(result.surface)))
    end
  end
end
