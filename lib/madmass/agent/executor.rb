
require "#{File.dirname(__FILE__)}/execution_monitor"

module Madmass
  module Agent
    module Executor
      include ExecutionMonitor

      def execute(usr_opts={})

        #prepare opts
        opts=usr_opts.clone
        opts[:agent] = self
        #opts[:cmd] = "Actions::"+ opts[:cmd]

        #create the action
        action = Madmass::Mechanics::ActionFactory.make(opts)

        #execute the action (transactional)
        perception = do_it action

        #dispatch percept
        dispatch_percepts

        #return the perception
        return perception;
      end


      # This is the method that fires the action execution. Any action instance previously created through the Mechanics::ActionFactory, can be executed by calling this method.
      # This method essentially checks the action preconditions by calling #applicable? method, then if the action is applicable call the #execute method,
      # otherwise it raise Madmass::Errors::NotApplicableError exception.
      #
      # Returns: a percept. You have to define the percept content (arranged in a hash) in the  #build_result method.
      #
      # Raises: Madmass::Errors::NotApplicableError

      def do_it action
        exec_monitor do
          # we are in a transaction!

          # check if the action is applicable in the current state
          unless action.state_match? or action.applicable_states.empty?
            raise Madmass::Errors::StateMismatchError, I18n.t(:'action.state_mistmatch',
              {:agent_state => Madmass.current_agent.status,
                :action_states => action.applicable_states.join(", ")})
          end

          # check action specific applicability
          raise Madmass::Errors::NotApplicableError, action.why_not_applicable unless action.applicable?

          # execute action
          action.execute

          # change user state
          action.change_state

          # generate percept (must be extracted within the transaction)
          action.build_result
        end

        return Madmass.current_percept
      end

      def dispatch_percepts

        Madmass.current_percept.each do |percept|

          topics = percept.header.topics
          #TODO @comm_strategy.send_to_topics(t, percept) if topics.any?

          clients = percept.header.clients
          #TODO @comm_strategy.send_to_clients(clients, percept) if clients.any?
        end
      end
    
    end
  end
end