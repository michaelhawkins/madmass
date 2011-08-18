module Madmass
  # This module must be included by classes that represents the agent that executes
  # the action. For example in a game the Agent can be the player etc.
  # The Agent is used by actions to check its status and execute the workflow defined
  # inside actions by the *action_states* and *next_state* directives.
  module Agent
    def self.included(base)
      base.class_eval do
        attr_accessor :status
        alias_method :initialize_without_check, :initialize
        alias_method :initialize, :initialize_with_check

        def status
          @status || :initial
        end
        
      end
    end

    private

    # Verify that che class that implements the agent has the required attributes.
    def initialize_with_check
      # attribute id is required
      raise Madmass::Errors::WrongInputError, "#{self.class} must have the required attribute 'id'!" unless defined?(self.id)
      initialize_without_check
    end

  end
end
