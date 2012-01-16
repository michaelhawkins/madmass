#This simple agent acts as a Proxy between the user and the environment.
# For this purpose if executes commands from the user, and dispatches percepts

module Madmass
  module Agent
    class ProxyAgent
      include Madmass::Agent::Executor
      attr_accessor :id, :status
      def initialize(options = {})
        options = HashWithIndifferentAccess.new(options)
        @status = options[:status] || :none
        @id = options[:id] || nil
      end
    end
  end
end
