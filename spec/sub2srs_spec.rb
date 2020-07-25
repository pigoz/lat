# frozen_string_literal: true

require_relative './fixtures/hibike.rb'

RSpec.describe Lat::Sub2srs do
  it 'works on a single file' do
    s = Lat::Sub2srs.new([HIBIKE1])
    skip
    ap s.card_data
    # expect(s.card_data).to eql({})
  end
end
