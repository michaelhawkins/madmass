module Madmass
  module Agent

    #The actions performed by this agent are executed in the background
    #*NOTE* requires Torquebox 2
    #FIXME use generator instead!

    class JmsExecutor < TorqueBox::Messaging::MessageProcessor
      #include Madmass::Agent::Executor

      def initialize
        super
      end

      def on_message(body)
        # notify that a command is received
        ActiveSupport::Notifications.instrument("madmass.command_received")

        # The body will be of whatever type was published by the Producer
        # the entire JMS message is available as a member variable called message()
        #code = execute(body)
        #raise "action did not succeed" unless code == 'ok'
        #agent = Madmass.current_agent || ProxyAgent.new
        message = JSON(body)
        Madmass.current_agent = Madmass::Agent::ProxyAgent.new(message.delete('agent'))
        Madmass.current_agent.execute(message)
      end
      
      #def on_error(exception)
      # You may optionally override this to interrogate the exception. If you do,
      # you're responsible for re-raising it to force a retry.
      #end

    end
  end
end