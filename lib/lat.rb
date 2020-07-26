# frozen_string_literal: true

require 'active_support/all'
require 'lat/version'

module Lat
  class Error < StandardError; end
  class AssertionError < StandardError; end

  def self.assert(message, &block)
    return if block.call

    raise AssertionError, "Assertion failed: #{message}"
  end

  def self.expand_settings_path(path)
    File.expand_path(path, File.dirname(__dir__))
  end

  def self.test?
    defined?(RSpec)
  end

  class S < Struct
    def self.new(*member_names)
      super(*member_names, keyword_init: true)
    end
  end
end

require 'config'

Config.setup do |config|
  config.schema do
    required(:anki).schema do
      required(:collection).filled(:str?)
      required(:export).schema do
        required(:deck_name).filled(:str?)
        required(:tag_name).filled(:str?)
        required(:note_type).filled(:str?)
      end
    end
    required(:blacklist).schema do
      required(:morphemes).schema do
        required(:active).filled(:bool?)
        required(:fields).array(:hash) do
          required(:note_type).filled(:str?)
          required(:field_name).filled(:str?)
        end
      end
      required(:files).value(:array, min_size?: 1).each(:str?)
    end
  end
end

Config.load_and_set_settings(
  Lat.expand_settings_path('share/lat.default.yaml'),
  Lat.test? ? Lat.expand_settings_path('share/lat.test.yaml') : nil,
  Lat.expand_settings_path('~/lat.yaml')
)

class Array
  def cartesian
    first.product(*self[1..-1])
  end
end

require 'lat/blacklist'
require 'lat/furigana'
require 'lat/lexer'
require 'lat/ffmpeg'
require 'lat/dict'
require 'lat/tts'
require 'lat/anki'
require 'lat/sub2srs'
require 'lat/text2srs'
require 'lat/mpv_script'
require 'lat/database'
