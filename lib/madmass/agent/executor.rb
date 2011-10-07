
module Madmass
  module Agent
    module Executor
      include Madmass::Transaction::TxMonitor
     
      def execute(usr_opts={})
                
        #prepare opts
        opts=usr_opts.clone
        opts[:agent] = self
        #opts[:cmd] = "Actions::"+ opts[:cmd]

        #Reset perception, that will be populated by the following actions
        Madmass.current_perception = []

        #create the action
        action = Madmass::Action::ActionFactory.make(opts)

        #execute the action (transactional)
        status = do_it action

        #dispatch generated percepts
        Madmass.dispatch_percepts

        #return the I18n perception
        return  status
      end


      # This is the method that fires the action execution. Any action instance previously created through the Action::ActionFactory, can be executed by calling this method.
      # This method essentially checks the action preconditions by calling #applicable? method, then if the action is applicable call the #execute method,
      # otherwise it raise Madmass::Errors::NotApplicableError exception.
      #
      # Returns: an http status Rails constant
      #
      # Raises: Madmass::Errors::NotApplicableError


      def do_it action

        tx_monitor do
          # we are in a transaction!

          # check if the action is applicable in the current state
          unless action.state_match? or action.applicable_states.empty?
            raise Madmass::Errors::StateMismatchError, I18n.t(:'action.state_mistmatch',
              {:agent_state => Madmass.current_agent.status,
                :action_states => action.applicable_states.join(", ")})
          end

          # check action specific applicability
          raise Madmass::Errors::NotApplicableError unless action.applicable?

          # execute action
          action.execute

          # change user state
          action.change_state

          # generate percept (in Madmass.current_percept)
          action.build_result
        end
        return :ok #http status

      rescue Madmass::Errors::StateMismatchError
        raise Madmass::Errors::StateMismatchError

      rescue Madmass::Errors::NotApplicableError => exc
        error_percept_factory(action, exc,
          :code => 'precondition_failed',
          :why_not_applicable => action.why_not_applicable.as_json)
        return :precondition_failed #http status

      rescue Madmass::Errors::WrongInputError => exc
        error_percept_factory(action, exc,
          :code => 'bad_request',
          :message => exc.message)
        return :bad_request #http status

      rescue Madmass::Errors::CatastrophicError => exc
        error_percept_factory(action, exc,
          :code => 'internal_server_error',
          :message => exc.message)
        return :internal_server_error #http status
        
      rescue Exception => exc
        error_percept_factory(action, exc,
          :code => 'service_unavailable',
          :message => exc.message)
        return :service_unavailable #http status
      end

      private
      
      def error_percept_factory(action, error, opts)

        Madmass.logger.error("#{error.class}: #{error.message}")

        e = Madmass::Perception::Percept.new(action)
        e.status = {:code => opts[:code], :exception => error.class.name}
        e.data.merge!({:message => opts[:message]}) if opts[:message]
        e.data.merge!({:why_not_applicable => opts[:why_not_applicable]}) if opts[:why_not_applicable]

        Madmass.current_perception << e
      end
 
    end
  end
end