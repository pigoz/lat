# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lat/version'

Gem::Specification.new do |spec|
  spec.name = 'lat'
  spec.version = Lat::VERSION
  spec.authors = ['Stefano Pigozzi']
  spec.email = %w[stefano.pigozzi@gmail.com]

  spec.summary = 'Tools to automate language acquisition through immersion.'
  spec.homepage = 'https://github.com/pigoz/lat'
  spec.license = 'AGPLv3'

  spec.files =
    Dir.chdir(File.expand_path(__dir__)) do
      `git ls-files -z`.split("\x0").reject do |f|
        f.match(%r{^(test|spec|features)/})
      end
    end

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '~> 13.0.1'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'rubocop', '~> 0.79.0'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'diff-lcs'
  spec.add_dependency 'google-cloud-text_to_speech'
  spec.add_dependency 'iconv'
  spec.add_dependency 'mojinizer'
  spec.add_dependency 'mpv'
  spec.add_dependency 'natto'
  spec.add_dependency 'parallel'
  spec.add_dependency 'rest-client'
  spec.add_dependency 'sequel'
  spec.add_dependency 'sqlite3'
end
