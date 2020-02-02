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
      surface: '暴力',
      surface_len: 6,
      surface_rlen: 6,
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
      surface: '見損なっ',
      surface_len: 12,
      surface_rlen: 13,
      x1: nil,
      x2: nil,
      x3: '五段・ワ行促音便',
      x4: '連用タ接続'
    )
  end

  it 'fetches charset' do
    expect(lexer.charset).to eql('utf-8')
  end

  it 'handles euc-jp ipadic' do
    s = "\xB5\xAD\xB9\xE6,\xB0\xEC\xC8\xCC,*,*,*,*,*"
    l = Lat::LexerJp.new
    l.charset = 'euc-jp'
    expect(l.decode(s)).to eql('記号,一般,*,*,*,*,*')
  end

  TESTS = [
    [
      '現在 全ての通常回線は 不通となっております',
      ' 現[げん] 在[ざい]  全[すべ]ての 通[つう] 常[じょう] 回[かい] 線[せん]は  不[ふ] 通[つう]となっております'
    ],
    [
      'お揃いの バッシュの紐もうれしかったし。',
      'お 揃[そろ]いの バッシュの 紐[ひも]もうれしかったし。'
    ],
    [
      '走り始めたら　俺は多分、自分の闘争心を抑えられないだろう',
      ' 走[はし]り 始[はじ]めたら　 俺[おれ]は 多[た] 分[ぶん]、 自[じ] 分[ぶん]の 闘[とう] 争[そう] 心[しん]を 抑[おさ]えられないだろう'
    ]
  ].freeze

  TESTS.each do |t|
    it "converts to furigana preserving whitespace #{t.first} => #{t.second}" do
      x = lexer.to_text(lexer.call(t.first))
      expect(x).to eql(t.second)
    end
  end
end
