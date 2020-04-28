# frozen_string_literal: true

RSpec.describe Lat::Dict do
  let(:dict) { Lat::Dict.new }

  it 'looks up kanji noun' do
    expect(dict.call(lemma: '漢字')).to eql(
      [
        Lat::Dict::Result.new(
          dictionary: 'myougiden',
          lemma: '漢字',
          grammar: 'n',
          definition: 'kanji | Chinese characters (P)',
          reading: 'かんじ'
        )
      ]
    )
  end

  it 'looks up kanji n,vsuru' do
    expect(dict.call(lemma: '勉強')).to eql(
      [
        Lat::Dict::Result.new(
          dictionary: 'myougiden',
          lemma: '勉強',
          grammar: 'n,vs',
          definition: 'study',
          reading: 'べんきょう'
        )
      ]
    )
  end

  it 'looks up katakana n' do
    expect(dict.call(lemma: 'パンツ')).to eql(
      [
        Lat::Dict::Result.new(
          dictionary: 'myougiden',
          lemma: 'パンツ',
          grammar: 'n',
          definition: 'underpants | pants',
          reading: 'パンツ'
        )
      ]
    )
  end

  it 'looks up hiragana verb' do
    expect(dict.call(lemma: 'ささやく')).to eql(
      [
        Lat::Dict::Result.new(
          dictionary: 'myougiden',
          lemma: '囁く',
          grammar: 'v5k,vi;uk',
          definition: 'to whisper | to murmur',
          reading: 'ささやく'
        )
      ]
    )
  end
end
