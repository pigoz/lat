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

  class S < Struct
    def self.new(*member_names)
      super(*member_names, keyword_init: true)
    end
  end
end

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
