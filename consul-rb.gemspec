
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require "consul-rb/version"

Gem::Specification.new do |s|
  s.name        = "consul-rb"
  s.version     = ConsulClient::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Alexander Piavlo"]
  s.email       = ["alex.p@supersonic.com"]
  s.homepage    = "https://github.com/SupersonicAds/consul-rb"
  s.summary     = "Consul HTTP Client"
  s.description = "Consul HTTP Client"
  s.license     = 'MIT'
  s.has_rdoc    = false

  s.add_development_dependency('rake')

  s.files         = Dir.glob("{lib}/**/*") + %w(consul-rb.gemspec LICENSE)
  s.test_files    = nil
  s.require_paths = ['lib']
end
