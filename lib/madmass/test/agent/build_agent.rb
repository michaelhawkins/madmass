module Madmass
  module Test

    # This class is used to simulate the agent that executes the actions.
    class BuildAgent
      include Madmass::Agent
      attr_accessor :action_applicable, :executions

      def initialize
        @action_applicable = false
        @executions = 0
      end
    end

  end
end
