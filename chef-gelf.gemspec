# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "chef/gelf/version"

Gem::Specification.new do |s|
  s.name        = "chef-gelf"
  s.version     = Chef::GELF::VERSION
  s.authors     = ["Jon Wood"]
  s.email       = ["jon@blankpad.net"]
  s.homepage    = "https://github.com/jellybob/chef-gelf"
  s.summary     = %q{Provides a Chef handler which reports run failures and changes to a Graylog2 server.}
  s.description = File.read("README.rdoc")

  s.rubyforge_project = "chef-gelf"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "gelf"
  s.add_dependency "chef"
end
