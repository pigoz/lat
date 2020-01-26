require 'mojinizer'
require 'natto'

module Lat
  class LexerJp
    def call(text)
      @mecab ||= mecab
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
      }

      QUERIES.each do |k, v|
        define_method :"#{k}?" do
          g1 == v.first
        end
      end

      def grammar
        QUERIES.each { |x, _| return x if public_send(:"#{x}?") }
        return g1.intern
      end

      def reading
        (reading1 || reading2)&.hiragana
      end
    end

    private

    def mecab
      dicdir = '/usr/local/lib/mecab/dic/mecab-ipadic-neologd/'
      Natto::MeCab.new(dicdir: dicdir)
    end

    def parse_result(result)
      split = result.feature.split(',')
      split = split.map { |x| x == '*' ? nil : x }
      feature = Hash[KEYS.zip(split.flatten)]
      Result.new(feature.merge(text: result.surface))
    end
  end
end
