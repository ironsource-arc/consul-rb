$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "consul/version"
 
task :build do
  system "gem build consul-rb.gemspec"
end

task :release => :build do
  system "gem push consul-rb-#{Consul::Client::VERSION}.gem"
end

task :gemfury => :build do
  system "curl -F package=@consul-rb-#{Consul::Client::VERSION}.gem $(cat .gemfury)"
end
