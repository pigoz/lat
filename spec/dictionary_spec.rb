# frozen_string_literal: true

def test_(lemma, expected)
  it "can find #{lemma}" do
    q = Lat::Dictionary::Query.new
    expect(q.count).to be > 0
    expect(q.call(lemma: lemma)).to eql([expected])
  end
end

RSpec.describe Lat::Dictionary do
  describe 'jmedict' do
    before(:all) {
      src = File.expand_path('./fixtures/JMdict_e', __dir__)
      Lat::Dictionary::LoadJmdict.new(src: src).call
    }

    it 'cant find stuff' do
      q = Lat::Dictionary::Query.new
      expect(q.count).to be > 0
      expect(q.call(lemma: '漢字')).to eql([])
    end

    test_("一期一会", Lat::Dictionary::Result.new(
      dictionary: 'JMdict_e',
      lemma: '一期一会',
      grammar: ['n'],
      definition: ["once-in-a-lifetime encounter (hence should be cherished as such)"],
      reading: ['いちごいちえ']
    ))

    test_("勉強", Lat::Dictionary::Result.new(
      dictionary: 'JMdict_e',
      lemma: '勉強',
      grammar: ['n', 'vs'],
      definition: ["study", "diligence", "discount", "reduction"],
      reading: ['べんきょう']
    ))
  end
end
