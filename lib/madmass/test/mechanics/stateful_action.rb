module Madmass
  module Test

    # This is a simple test action.
    class StatefulAction < Madmass::Mechanics::Action
      action_states :state1, :state2
      next_state :state3


      def execute
        true
      end

    end

  end
end