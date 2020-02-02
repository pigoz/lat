module Lat
  class Blacklist
    def self.default
      @default ||= NullBlacklist.new
    end

    def self.clear_default
      @default = nil
    end

    class << self
      attr_writer :default
    end
  end

  class NullBlacklist
    def blacklisted?(*)
      false
    end
  end

  class FileBlacklist
    def initialize(path)
      @blacklist = IO.read(path).strip.split("\n")
    end

    def blacklisted?(lemma)
      @blacklist.include?(lemma)
    end
  end
end
