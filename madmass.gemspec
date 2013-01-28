# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "madmass/version"

Gem::Specification.new do |s|
  s.name = "madmass"
  s.version = Madmass::VERSION
  s.authors = ["ziparo"]
  s.email = ["ziparo@algorithmica.it"]
  s.homepage = "https://github.com/algorithmica/madmass"
  s.summary = %q{MAssively Distributed Multi-Agent System Simulator}
  s.description = %q{MADMASS is an open-source Ruby on Rails gem for developing
MAssively Distributed Multi Agent System Simulators. MADMASS is a framework for
developing web applications that featuring scalability and real-time interactions among users.
Target applications include, but are not limited to, Multi-Player Online Games,
Transaction Processing Systems, Location-based Mobile Social Networks (or geo-social networks)
 and cooperative systems (e.g.,crowd-sourcing apps).}

  s.rubyforge_project = "madmass"

  s.files = `git ls-files -- {LICENSE.txt,Rakefile,README.md} {app,config,db,lib}/*`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_dependency "shoulda", ">= 0"
  s.add_dependency "bundler"
  s.add_dependency "rcov", "~> 0.9.11"
  s.add_dependency "torquebox-rake-support"
  s.add_dependency "torquebox", "2.3.0"
  # FIXME: uncomment when agent farm will be published and remove from Gemfile of client apps
  #s.add_dependency "agent_farm"

  #s.add_dependency 'i18n'
  #s.add_dependency "activesupport"
  s.add_dependency "rails"
end
