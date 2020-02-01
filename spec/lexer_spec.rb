# frozen_string_literal: true

RSpec.describe Lat::LexerJp do
  let(:lexer) { Lat::Lexer.get(:jp).new }

  it 'lexes a simple sentence' do
    r = lexer.call('暴力を振るって 人を傷つけるなんて— 最低よ！ 見損なったわ！')
    expect(r.size).to eql(17)
    r1 = r.first
    expect(r1).to be_noun
    expect(r1.grammar).to eql(:noun)
    expect(r1.reading).to eql('ぼうりょく')
    expect(r1.to_h).to eql(
      g1: '名詞',
      g2: '一般',
      lemma: '暴力',
      reading1: 'ボウリョク',
      reading2: 'ボーリョク',
      text: '暴力',
      x1: nil,
      x2: nil,
      x3: nil,
      x4: nil
    )

    r12 = r[12]
    expect(r12).to be_verb
    expect(r12.grammar).to eql(:verb)
    expect(r12.reading).to eql('みそこなっ')
    expect(r12.to_h).to eql(
      g1: '動詞',
      g2: '自立',
      lemma: '見損なう',
      reading1: 'ミソコナッ',
      reading2: 'ミソコナッ',
      text: '見損なっ',
      x1: nil,
      x2: nil,
      x3: '五段・ワ行促音便',
      x4: '連用タ接続'
    )
  end

  it 'handles euc-jp ipadic' do
    s = "\xB5\xAD\xB9\xE6,\xB0\xEC\xC8\xCC,*,*,*,*,*"
    d = Lat::LexerJp.new(mecab_encoding: 'euc-jp').decode(s)
    expect(d).to eql('記号,一般,*,*,*,*,*')
  end
end
