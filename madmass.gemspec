# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{madmass}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Algorithmica Srl"]
  s.date = %q{2011-08-31}
  s.description = %q{madmass (MAssively Distributed Multi-Agent System Simulator) is a framework for designing web based multi agent system simulations, with a massive number of agents.}
  s.email = %q{info@algorithmica.it}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "config/locales/madmass_en.yml",
    "config/locales/madmass_it.yml",
    "lib/agent.rb",
    "lib/atomic.rb",
    "lib/comm.rb",
    "lib/errors.rb",
    "lib/madmass.rb",
    "lib/madmass/agent/agent.rb",
    "lib/madmass/agent/current.rb",
    "lib/madmass/atomic/active_record_adapter.rb",
    "lib/madmass/atomic/none_adapter.rb",
    "lib/madmass/atomic/transaction_manager.rb",
    "lib/madmass/comm/comm_strategy.rb",
    "lib/madmass/comm/dummy_comm_strategy.rb",
    "lib/madmass/comm/helper.rb",
    "lib/madmass/comm/message_builder.rb",
    "lib/madmass/comm/perception_sender.rb",
    "lib/madmass/comm/socky_sender.rb",
    "lib/madmass/comm/standard_comm_strategy.rb",
    "lib/madmass/comm/standard_sender.rb",
    "lib/madmass/errors/catastrophic_error.rb",
    "lib/madmass/errors/not_applicable_error.rb",
    "lib/madmass/errors/state_mismatch_error.rb",
    "lib/madmass/errors/wrong_input_error.rb",
    "lib/madmass/mechanics/action.rb",
    "lib/madmass/mechanics/action_factory.rb",
    "lib/madmass/mechanics/monitorable.rb",
    "lib/madmass/mechanics/stateful.rb",
    "lib/madmass/test/agent/build_agent.rb",
    "lib/madmass/test/agent/real_agent.rb",
    "lib/madmass/test/agent/wrong_agent.rb",
    "lib/madmass/test/comm/fake_comm_strategy.rb",
    "lib/madmass/test/config/madmass_config.yml",
    "lib/madmass/test/mechanics/build_action.rb",
    "lib/madmass/test/mechanics/simple_action.rb",
    "lib/madmass/test/mechanics/stateful_action.rb",
    "lib/madmass/test/tracer/ar_object.rb",
    "lib/madmass/test/tracer/traceable_object.rb",
    "lib/madmass/tracer/tracer.rb",
    "lib/madmass/utils/config.rb",
    "lib/madmass/utils/env.rb",
    "lib/madmass/utils/logger.rb",
    "lib/test.rb",
    "lib/tracer.rb",
    "lib/utils.rb",
    "test/helper.rb",
    "test/test_action.rb",
    "test/test_agent.rb",
    "test/test_comm.rb",
    "test/test_config.rb",
    "test/test_tracer.rb",
    "test/test_transaction_manager.rb"
  ]
  s.homepage = %q{http://github.com/algorithmica/madmass}
  s.licenses = ["GNU AGPL"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{madmass (MAssively Distributed Multi-Agent System Simulator) is a framework for designing web based multi agent system simulations, with a massive number of agents.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<i18n>, [">= 0"])
      s.add_development_dependency(%q<activesupport>, [">= 0"])
      s.add_development_dependency(%q<activerecord>, [">= 3.0.0"])
    else
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<i18n>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<activerecord>, [">= 3.0.0"])
    end
  else
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<i18n>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<activerecord>, [">= 3.0.0"])
  end
end
