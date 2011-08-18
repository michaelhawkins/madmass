module Madmass
  module Test

    # This class is used to simulate the agent that executes the actions.
    class RealAgent
      attr_reader :id

      def initialize
        # the agent must have the id attribute
        @id = rand(Time.now)
      end

      include Madmass::Agent
    end

  end
end
