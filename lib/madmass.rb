MADMASS_ROOT = File.dirname(__FILE__) unless defined?(MADMASS_ROOT)

module Madmass
  class << self
    def root
      MADMASS_ROOT
    end    
  end
end

require File.join(Madmass.root, 'tracer')
require File.join(Madmass.root, 'errors')
require File.join(Madmass.root, 'utils')
require File.join(Madmass.root, 'madmass', 'mechanics', 'action_factory')
require File.join(Madmass.root, 'comm')
require File.join(Madmass.root, 'atomic')

module Madmass
  class << self
    include Madmass::Utils::Loggable
    include Madmass::Utils::Env
    include Madmass::Utils::Configurable
    include Madmass::Atomic
  end
end