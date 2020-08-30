# frozen_string_literal: true

require 'active_support/all'
require 'lat/version'
require 'config'
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

  XDG_DEFAULTS = {
    'XDG_DATA_HOME' => '~/.local/share',
    'XDG_CONFIG_HOME' => '~/.config',
    'XDG_CACHE_HOME' => '~/.cache'
  }.freeze

  def self.xdg(type, path)
    var = "XDG_#{type.to_s.upcase}_HOME"
    root = ENV[var] || XDG_DEFAULTS[var]
    File.expand_path(File.join(root, 'lat', path))
  end

  def self.xdg!(type, path)
    require 'fileutils'
    result = xdg(type, path)
    dir = File.dirname(result)
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    result
  end

  def self.test?
    defined?(RSpec)
  end

  def self.load_config_files(*additional)
    Config.load_and_set_settings(
      Lat.expand_settings_path('share/lat.default.yaml'),
      Lat.test? ? Lat.expand_settings_path('share/lat.test.yaml') : nil,
      Lat.xdg(:config, 'config.yaml'),
      Lat.expand_settings_path('~/lat.yaml'),
      *additional
    )
  end

  def self.with_config_files(*files, &block)
    load_config_files(*files)
    block.call
  ensure
    load_config_files
  end

  class S < Struct
    def self.new(*member_names)
      super(*member_names, keyword_init: true)
    end
  end
end

Config.setup do |config|
  config.schema do
    required(:anki).schema do
      required(:collection).filled(:str?)
      required(:export).schema do
        required(:deck_name).filled(:str?)
        required(:tag_name).filled(:str?)
        required(:note_type).filled(:str?)
      end
      required(:fields).schema do
        optional(:line).filled(:str?)
        optional(:reading).filled(:str?)
        optional(:words).maybe(:str?)
        optional(:image).maybe(:str?)
        optional(:sound).maybe(:str?)
        optional(:source).maybe(:str?)
        optional(:time).maybe(:str?)
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

class Array
  def cartesian
    first.product(*self[1..-1])
  end
end

Lat.load_config_files

require 'lat/blacklist'
require 'lat/furigana'
require 'lat/lexer'
require 'lat/ffmpeg'
require 'lat/dictionary/result'
require 'lat/dictionary/downloader'
require 'lat/dictionary/load_jmdict'
require 'lat/dictionary/query'
require 'lat/dict'
require 'lat/tts'
require 'lat/anki'
require 'lat/sub2srs'
require 'lat/text2srs'
require 'lat/mpv_script'
require 'lat/database'
