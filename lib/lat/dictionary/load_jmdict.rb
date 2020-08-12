# frozen_string_literal: true

require 'open-uri'
require 'zlib'

module Lat
  module Dictionary
    class LoadJmdict
      def initialize(src:)
        @src = src
      end

      def call
        require 'nokogiri'
        require 'parallel'

        name = File.basename(@src)
        xml = Nokogiri::XML(File.open(@src))
        words = xml.css('entry')

        Parallel.each(words, in_threads: 16, progress: name) do |word|
          insert_word(name, parse_word(word))
        end
      end

      def parse_word(word)
        {
          id: word.css('ent_seq').map(&:text).first,
          lemma: word.css('k_ele keb').map(&:text),
          reading: word.css('r_ele reb').map(&:text),
          pos: word.css('sense pos').flat_map(&:children).map(&:name),
          gloss: word.css('sense gloss').map(&:text)
        }
      end

      def insert_word(name, word)
        entry = Query.db[:entries].insert(
          dictionary: name,
          dictionary_id: word[:id].to_s,
          pos: word[:pos].to_json,
          gloss: word[:gloss].to_json,
          reading: word[:reading].to_json
        )
        word[:lemma].each do |lemma|
          Query.db[:lemmas].insert(entry_id: entry, lemma: lemma)
        end
      rescue Sequel::UniqueConstraintViolation
        # XXX: add Lat.log
        puts("[#{name}] word #{word} already exists")
      end
    end
  end
end
