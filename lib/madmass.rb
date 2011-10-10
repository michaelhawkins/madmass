MADMASS_ROOT = File.dirname(__FILE__) unless defined?(MADMASS_ROOT)

module Madmass
  class << self
    def root
      MADMASS_ROOT
    end

    def gem_root
      File.join(Madmass.root, '..')
    end

    def config_root
      File.join(Madmass.root, '..', 'config')
    end
  end
end

require File.join(Madmass.root, 'tracer')
require File.join(Madmass.root, 'errors')
require File.join(Madmass.root, 'utils')
require File.join(Madmass.root, 'madmass', 'action', 'action_factory')
require File.join(Madmass.root, 'comm')
require File.join(Madmass.root, 'transaction')
require File.join(Madmass.root, 'agent')
require File.join(Madmass.root, 'perception')

module Madmass
  class << self
    include Madmass::Utils::Loggable
    include Madmass::Utils::Env
    include Madmass::Utils::Configurable
    include Madmass::Transaction
    include Madmass::Agent::Current
    include Madmass::Perception::Current
    include Madmass::Comm::Dispatcher
  end
end