module Lat
  class Dict
    Result =
      Struct.new(
        :dictionary,
        :lemma,
        :definition,
        :reading,
        :grammar,
        keyword_init: true
      )

    def self.get(iso2:)
      Kernel.const_get("Lat::Dict#{iso2.capitalize}")
    end

    def lookup(lemma:)
      raise NotImplementedError, 'lookup is not implemented'
    end
  end
end
