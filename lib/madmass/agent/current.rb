module Madmass
  module Agent

    # This is the Singleton class that holds the current agent instance.
    class CurrentAccessor
      #include Singleton
      attr_accessor :agent
    end

    # This module is used to provide a global access to the current agent executing the
    # action in all classes by invoking Madmass.current_agent.
    module Current
      def current_agent
        #Agent::CurrentAccessor.instance.agent
        @agent ||= Madmass::Agent::ProxyAgent.new
      end

      def current_agent=(agent)
        #Agent::CurrentAccessor.instance.agent = agent
        @agent = agent
      end
    end
  end

end
