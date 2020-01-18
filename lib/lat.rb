require 'active_support/all'
ActiveSupport::Dependencies.autoload_paths += %w[lib]

require 'lat/version'

module Lat
  class Error < StandardError; end
end
