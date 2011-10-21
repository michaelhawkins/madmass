module Madmass
  module Agent

    #The actions performed by this agent are executed in the background
    #*NOTE* requires Torquebox 2
    #FIXME use generator instead!

    class JmsExecutor < TorqueBox::Messaging::MessageProcessor
      include Madmass::Agent::Executor
      include TorqueBox::Injectors
     

      def create
        @execution_queue = inject( '/queues/execute' )
      end

      def on_message(body)
        # The body will be of whatever type was published by the Producer
        # the entire JMS message is available as a member variable called message()
        code = execute(body)
        raise "action did not succeed" unless code == 'ok'
      end
      #def on_error(exception)
      # You may optionally override this to interrogate the exception. If you do,
      # you're responsible for re-raising it to force a retry.
      #end

    end
  end
end