lib = File.expand_path('../lib', __FILE__)
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
    Dir.chdir(File.expand_path('..', __FILE__)) do
      `git ls-files -z`.split("\x0").reject do |f|
        f.match(%r{^(test|spec|features)/})
      end
    end

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
