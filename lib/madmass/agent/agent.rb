require "#{File.dirname(__FILE__)}/executor"
require "#{File.dirname(__FILE__)}/f_s_a_executor"
module Madmass
  # This module must be included by classes that represents the agent that executes
  # the action. For example in a game the Agent can be the player etc.
  # The Agent is used by actions to check its status and execute the workflow defined
  # inside actions by the *action_states* and *next_state* directives.
  module Agent
    include Madmass::Agent::FSAExecutor

    
  end


end
