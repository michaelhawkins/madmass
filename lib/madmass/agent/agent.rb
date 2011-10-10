require "#{File.dirname(__FILE__)}/executor"

module Madmass
  # This module must be included by classes that represents the agent that executes
  # the action. For example in a game the Agent can be the player etc.
  # The Agent is used by actions to check its status and execute the workflow defined
  # inside actions by the *action_states* and *next_state* directives.
  module Agent
    include  Madmass::Agent::Executor

    def self.included(base)
      base.class_eval do
        alias_method :initialize_without_check, :initialize
        alias_method :initialize, :initialize_with_check
      end
    end
    
    private

    # Verify that che class that implements the agent has the required attributes.
    def initialize_with_check args = nil
      # attribute id is required
      raise Madmass::Errors::WrongInputError, "#{self.class} must have the required attribute 'id'!" unless defined?(self.id)
      begin
        self.status
      rescue NoMethodError
        raise Madmass::Errors::WrongInputError, "#{self.class} must have the required attribute 'status'!"
      end
      if args
        initialize_without_check args
      else
        initialize_without_check
      end
    end

  end


end
