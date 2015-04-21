lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require "consul/version"

Gem::Specification.new do |s|
  s.name        = "consul-rb"
  s.version     = Consul::Client::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Alexander Piavlo"]
  s.email       = ["alex.p@supersonic.com"]
  s.homepage    = "https://github.com/SupersonicAds/consul-rb"
  s.summary     = "Consul HTTP Client"
  s.description = "Consul HTTP Client Ruby Library"
  s.license     = 'MIT'
  s.has_rdoc    = false

  s.add_development_dependency('rake-compiler', '~> 10')

  s.files         = Dir.glob("{lib}/**/*") + %w(consul-rb.gemspec LICENSE)
  s.test_files    = nil
  s.require_paths = ['lib']
end
