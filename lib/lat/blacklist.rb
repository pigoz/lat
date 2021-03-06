# frozen_string_literal: true

module Lat
  class Blacklist
    def self.default
      @default ||= SettingsBlacklist.new
    end

    def self.clear_default
      @default = nil
    end

    class << self
      attr_writer :default
    end
  end

  class SettingsBlacklist
    def initialize
      fs = Settings.blacklist.files.map { |x| Lat.expand_settings_path(x) }
      @xs = fs.map { |f| FileBlacklist.new(f) }
      @xs.push(MorphemesBlacklist.new) if Settings.blacklist.morphemes.active
    end

    def blacklisted?(lemma)
      @xs.any? { |x| x.blacklisted?(lemma) }
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

  class MorphemesBlacklist
    def initialize
      @morphemes = Lat::Database.new.morphemes.to_set
    end

    def blacklisted?(lemma)
      @morphemes.include?(lemma)
    end
  end
end
