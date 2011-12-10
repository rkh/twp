$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'twp/version'

Gem::Specification.new do |s|
  s.name        = 'twp'
  s.version     = ::TWP::VERSION
  s.summary     = "Implementation of TWP3"
  s.description = "An implementation of The Wire Protocol 3 in Ruby"
  s.homepage    = "http://github.com/rkh/twp"

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- spec`.split("\n")
  s.executables = `git ls-files -- bin`.split("\n").map { |f| File.basename(f) }
  s.authors     = `git shortlog -sn`.scan(/[^\d\s].*/)
  s.email       = `git shortlog -sne`.scan(/[^<]+@[^>]+/)

  s.add_dependency 'kpeg', '~> 0.8.4'
  s.add_dependency 'tool', '~> 0.1.1'
  s.add_development_dependency 'rspec', '~> 2.7'
end
