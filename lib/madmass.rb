MADMASS_ROOT = File.dirname(__FILE__) unless defined?(MADMASS_ROOT)

module Madmass
  class << self
    def root
      MADMASS_ROOT
    end

    def config_root
      File.join(Madmass.root, '..', 'config')
    end
  end
end

require File.join(Madmass.root, 'tracer')
require File.join(Madmass.root, 'errors')
require File.join(Madmass.root, 'utils')
require File.join(Madmass.root, 'madmass', 'mechanics', 'action_factory')
require File.join(Madmass.root, 'comm')
require File.join(Madmass.root, 'atomic')
require File.join(Madmass.root, 'agent')
require File.join(Madmass.root, 'percept')

module Madmass
  class << self
    include Madmass::Utils::Loggable
    include Madmass::Utils::Env
    include Madmass::Utils::Configurable
    include Madmass::Atomic
    include Madmass::Agent::Current
    include Madmass::Percept::Current
  end
end