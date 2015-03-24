# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gocdkit/version'

Gem::Specification.new do |spec|
  spec.add_development_dependency 'bundler', '~> 1.0'
  spec.add_dependency 'sawyer', '>= 0.5.3', '~> 0.6.0'
  spec.add_dependency 'xml-simple', '>= 1.1.5'
  spec.authors = ["Wynn Netherland", "Erik Michaels-Ober", "Clint Shryock"]
  spec.description = %q{Wrapper for the go-server (go.cd) API}
  spec.email = ['pk.hzzrd@gmail.com']
  spec.files = %w(.document CONTRIBUTING.md LICENSE.md README.md Rakefile gocdkit.gemspec)
  spec.files += Dir.glob("lib/**/*.rb")
  spec.homepage = 'https://github.com/PagerDuty/gocdkit'
  spec.name = 'gocdkit'
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 1.9.2'
  spec.required_rubygems_version = '>= 1.3.5'
  spec.summary = "Ruby toolkit for working with the go-server (go.cd) API"
  spec.version = Gocdkit::VERSION.dup
end
