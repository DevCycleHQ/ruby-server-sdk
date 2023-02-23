# -*- encoding: utf-8 -*-

=begin
#DevCycle Bucketing API
#Documents the DevCycle Bucketing API which provides and API interface to User Bucketing and for generated SDKs.
The version of the OpenAPI document: 1.0.0
Generated by: https://openapi-generator.tech
OpenAPI Generator version: 5.3.0
=end

$:.push File.expand_path("../lib", __FILE__)
require "devcycle-ruby-server-sdk/version"

Gem::Specification.new do |s|
  s.name        = "devcycle-ruby-server-sdk"
  s.version     = DevCycle::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["DevCycleHQ"]
  s.email       = ["support@devcycle.com"]
  s.homepage    = "https://devcycle.com"
  s.summary     = "DevCycle Bucketing API Ruby Gem"
  s.description = "DevCycle Ruby Server SDK, for interacting with feature flags created with the DevCycle platform."
  s.license     = "MIT"
  s.required_ruby_version = ">= 2.4"

  s.add_runtime_dependency 'typhoeus', '~> 1.0', '>= 1.0.1'
  s.add_runtime_dependency 'wasmtime', '5.0.0'
  s.add_runtime_dependency 'concurrent-ruby', '1.2.0'
  s.add_runtime_dependency 'sorbet-runtime', '0.5.10648'
  s.add_runtime_dependency 'oj', '3.13.2'


  s.add_development_dependency 'rspec', '~> 3.6', '>= 3.6.0'

  s.files         = Dir['README.md', 'LICENSE',
                        'lib/**/*',
                        'devcycle-ruby-server-sdk.gemspec',
                        'Gemfile']
  s.test_files    = `find spec/*`.split("\n")
  s.executables   = []
  s.require_paths = ["lib"]
end
