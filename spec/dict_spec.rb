RSpec.describe Lat::Dict do
  it 'looks up japanese kanji noun' do
    dict = Lat::Dict.get(iso2: :jp).new
    expect(dict.lookup(lemma: '漢字')).to eql(
      [
        Lat::Dict::Result.new(
          dictionary: 'myougiden',
          lemma: '漢字',
          grammar: 'n',
          definition: 'Chinese characters|kanji (P)',
          reading: 'かんじ'
        )
      ]
    )
  end

  it 'looks up japanese kanji n,vsuru' do
    dict = Lat::Dict.get(iso2: :jp).new
    expect(dict.lookup(lemma: '勉強')).to eql(
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

  it 'looks up japanese katakana n' do
    dict = Lat::Dict.get(iso2: :jp).new
    expect(dict.lookup(lemma: 'アイドル')).to eql(
      [
        Lat::Dict::Result.new(
          dictionary: 'myougiden',
          lemma: 'アイドル',
          grammar: 'n',
          definition:
            'entertainer whose image is manufactured to cultivate a dedicated consumer fan following',
          reading: 'アイドル'
        ),
        Lat::Dict::Result.new(
          dictionary: 'myougiden',
          lemma: 'アイドル',
          grammar: 'adj-f',
          definition: 'idle',
          reading: 'アイドル'
        )
      ]
    )
  end

  it 'looks up japanese hiragana verb' do
    dict = Lat::Dict.get(iso2: :jp).new
    expect(dict.lookup(lemma: 'ささやく')).to eql(
      [
        Lat::Dict::Result.new(
          dictionary: 'myougiden',
          lemma: '囁く',
          grammar: 'v5k,vi;uk',
          definition: 'to whisper|to murmur',
          reading: 'ささやく'
        )
      ]
    )
  end
end
