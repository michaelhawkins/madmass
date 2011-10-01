#This simple agent acts as a Proxy between the user and the environment.
# For this purpose if executes commands from the user, and dispatches percepts

module Madmass
  module Agent
    class ProxyAgent
      include Madmass::Agent
      def initialize
        @status = :none
      end
    end
  end
end
