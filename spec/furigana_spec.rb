# frozen_string_literal: true

RSpec.describe Lat::Furigana do
  tests = [
    ['勉強', 'べんきょう', ' 勉[べん] 強[きょう]'],
    ['単行本', 'たんこうぼん', ' 単[たん] 行[こう] 本[ぼん]'],
    ['見損なった', 'みそこなった', ' 見[み] 損[そこ]なった'],
    ['絶対', 'ぜったい', ' 絶[ぜっ] 対[たい]'],
    ['寝不足', 'ねぶそく', ' 寝[ね] 不[ぶ] 足[そく]'],
    ['威張る', 'いばる', ' 威[い] 張[ば]る'],
    ['煙草', 'たばこ', ' 煙[たば] 草[こ]'],
    ['益々', 'ますます', ' 益[ます]々'],
    ['田辺', 'たなべ', ' 田[た] 辺[なべ]'],
    ['人間', 'にんげん', ' 人[にん] 間[げん]']
  ].freeze

  tests.each do |t|
    it "works with #{t.first} => #{t.third}" do
      x = Lat::Furigana.new.call(text: t.first, reading: t.second)
      expect(x).to eql(t.third)
    end
  end

  xit 'generates database' do
    Lat::DownloadDatabase.new.call
  end
end
