# frozen_string_literal: true

module Lat
  class Dict
    include Lat::Factory

    Result =
      Struct.new(
        :dictionary,
        :lemma,
        :definition,
        :reading,
        :grammar,
        keyword_init: true
      )
  end
end
