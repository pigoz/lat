
# frozen_string_literal: true

RSpec.describe Lat::Database do
  it 'generates database' do
    db = Lat::Database.new
    morphemes = db.morphemes
    expect(morphemes).to include('です')
    expect(db.morphemes_for('脊髄') - morphemes).to eql([])
  end
end
