module Madmass
  # This module must be included by classes that represents the agent that executes
  # the action. For example in a game the Agent can be the player etc.
  # The Agent is used by actions to check its status and execute the workflow defined
  # inside actions by the *action_states* and *next_state* directives.
  module Agent
    def self.included(base)
      base.class_eval do
        # TODO: delete dependency if possible
        if base.ancestors.include?(ActiveRecord::Base)
          base.send(:include, Madmass::ActiveRecordAgent)
        else
          attr_accessor :status
          alias_method :initialize_without_check, :initialize
          alias_method :initialize, :initialize_with_check
        end        
      end
    end

    private

    # Verify that che class that implements the agent has the required attributes.
    def initialize_with_check args = nil
      # attribute id is required
      raise Madmass::Errors::WrongInputError, "#{self.class} must have the required attribute 'id'!" unless defined?(self.id)
      if args
        initialize_without_check args
      else
        initialize_without_check
      end
    end

  end

  module ActiveRecordAgent
    def status=(state)
      write_attribute(:status, state)
      save
    end
  end
end
