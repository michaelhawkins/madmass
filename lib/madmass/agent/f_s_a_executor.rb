# To change this template, choose Tools | Templates
# and open the template in the editor.

module Madmass
  module Agent
    module FSAExecutor

      def self.included(base)
        base.send(:include, Madmass::Agent::Executor)
      end
    
      private
      
      # Verify that che class that implements the agent has the required attributes.
      def check_status args = nil
        # attribute id status required
        self.status
      rescue NoMethodError
        raise Madmass::Errors::WrongInputError, "#{self.class} must have the required attribute 'status'!"
      end

      def behavioral_validation action
        check_status
        unless action.state_match? or action.applicable_states.empty?
          raise Madmass::Errors::StateMismatchError, I18n.t(:'action.state_mistmatch',
            {:agent_state => Madmass.current_agent.status,
              :action_states => action.applicable_states.join(", ")})
        end
      end
      
    end
  end
end
