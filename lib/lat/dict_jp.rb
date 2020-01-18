module Lat
  class DictJp
    def lookup(lemma:)
      results = `myougiden --color=no -t #{lemma}`.strip.split("\n")
      results.map do |result|
        parts = result.split("\t")
        d = parse_definition(parts.third)
        Lat::Dict::Result.new(
          dictionary: 'myougiden',
          lemma: first_item(parts.second) || lemma,
          grammar: d.fetch('grammar'),
          definition: d.fetch('definition'),
          reading: first_item(parts.first)
        )
      end
    end

    def first_item(x)
      x.split('；').first
    end

    def parse_definition(x)
      regexp = /\[(?<grammar>.+)\]\s(?<definition>.+)/
      regexp.match(x).named_captures
    end
  end
end
