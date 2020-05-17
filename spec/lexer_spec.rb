# frozen_string_literal: true

RSpec.describe Lat::Lexer do
  let(:lexer) { Lat::Lexer.new }

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
    l = Lat::Lexer.new
    l.charset = 'euc-jp'
    expect(l.decode(s)).to eql('記号,一般,*,*,*,*,*')
  end

  tests = [
    [
      '現在 全ての通常回線は 不通となっております',
      ' 現[げん] 在[ざい]  全[すべ]ての 通[つう] 常[じょう] 回[かい] 線[せん]は  不[ふ] 通[つう]となっております',
      '現在 全ての 通[つう] 常[じょう] 回[かい] 線[せん]は  不[ふ] 通[つう]となっております',
      '通常,つうじょう|回線,かいせん|不通,ふつう'
    ],
    [
      'お揃いの バッシュの紐もうれしかったし。',
      'お 揃[そろ]いの バッシュの 紐[ひも]もうれしかったし。',
      'お揃いの バッシュの 紐[ひも]もうれしかったし。',
      'バッシュ,バッシュ|紐,ひも'
    ],
    [
      '走り始めたら　俺は多分、自分の闘争心を抑えられないだろう',
      ' 走[はし]り 始[はじ]めたら　 俺[おれ]は 多[た] 分[ぶん]、 自[じ] 分[ぶん]の 闘[とう] 争[そう] 心[しん]を 抑[おさ]えられないだろう',
      '走り始めたら　俺は多分、自分の 闘[とう] 争[そう]心を 抑[おさ]えられないだろう',
      '闘争,とうそう|抑える,おさえる'
    ],
    [
      '何でみんなダメ金なんかで喜べるの',
      ' 何[なん]でみんなダメ 金[きん]なんかで 喜[よろこ]べるの',
      '何でみんなダメ金なんかで喜べるの',
      '駄目,だめ'
    ],
    [
      '私ら全国目指してたんじゃないの？',
      ' 私[わたし]ら 全[ぜん] 国[こく] 目[め] 指[ざ]してたんじゃないの？',
      '私ら 全[ぜん] 国[こく] 目[め] 指[ざ]してたんじゃないの？',
      '全国,ぜんこく|目指す,めざす'
    ],
    [
      '私アサミに報告してくる',
      ' 私[わたし]アサミに 報[ほう] 告[こく]してくる',
      '私アサミに 報[ほう] 告[こく]してくる',
      'アサ,アサーティブネストレーニング|ミ,ミ|報告,ほうこく'
    ],
    [
      'あの子緊張でトイレに閉じこもってるから',
      'あの 子[こ] 緊[きん] 張[ちょう]でトイレに 閉[と]じこもってるから',
      'あの子緊張でトイレに 閉[と]じこもってるから',
      'トイレ,トイレ|閉じこもる,とじこもる'
    ],
    [
      'some text in english',
      'some text in english',
      'some text in english',
      ''
    ],
    [
      'まだまだ 獣人と人間の溝は 消えてはいません',
      'まだまだ  獣[ししう] 人[じん]と 人[にん] 間[げん]の 溝[みぞ]は  消[き]えてはいません',
      'まだまだ  獣[ししう]人と 人[にん] 間[げん]の 溝[みぞ]は  消[き]えてはいません',
      '獣,しし|人間,にんげん|溝,みぞ|消える,きえる'
    ]
  ].freeze

  tests.each do |t|
    it "converts to furigana (nbl) #{t.first}" do
      Lat::Blacklist.clear_default
      x = lexer.to_text(lexer.call(t.first))
      expect(x).to eql(t.second)
    end

    it "converts to furigana (fbl) #{t.first}" do
      path = File.expand_path('./blacklist.txt', __dir__)
      Lat::Blacklist.default = Lat::FileBlacklist.new(path)
      x = lexer.to_text(lexer.call(t.first))
      expect(x).to eql(t.third)
    end

    it "looks up lemmas into dictionary (fbl) #{t.first}" do
      path = File.expand_path('./blacklist.txt', __dir__)
      Lat::Blacklist.default = Lat::FileBlacklist.new(path)
      x = lexer.to_definitions(lexer.call(t.first)).map { |d| "#{d.lemma},#{d.reading}" }.join('|')
      expect(x).to eql(t.fourth)
    end
  end
end
