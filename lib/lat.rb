# frozen_string_literal: true

require 'active_support/all'
ActiveSupport::Dependencies.autoload_paths += %w[lib]

require 'lat/version'

module Lat
  class Error < StandardError; end
  class AssertionError < StandardError; end

  def self.assert(&block)
    return if block.call

    raise AssertionError, "Assertion failed #{block.to_source}"
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
