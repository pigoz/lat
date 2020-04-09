#!/usr/bin/env ruby
# frozen_string_literal: true

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)
ENV['GOOGLE_APPLICATION_CREDENTIALS'] ||=
  File.expand_path('../google-cloud-key.json', __dir__)

require 'rubygems'
require 'bundler/setup'

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'mpv'
require 'lat'

text = ARGV.first
source = ARGV.second

path = File.expand_path('./../spec/blacklist.txt', __dir__)
Lat::Blacklist.default = Lat::FileBlacklist.new(path)

puts Lat::Text2srs.new(text, source).call.first
