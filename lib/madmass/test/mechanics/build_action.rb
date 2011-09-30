# This action builds a city.
#
# === Accepted parameters
# * *initial_placement*: [true|false], this param is ignored by this action
#   because you cannot place a city where there are no colonies. This param
#   is however necessary because it's always passed by the client for build actions.
# * *target*: 6 vertex coordinates (ex: [0,0,0,-1,1,-1])
#
# === Applicability
# * Player has not depleted he's cities.
# * Player has enough resources to build the city.
# * The city is placed over an existing and owned colony.
#
# === Trace
# * Currente player
# * Current game
#
# === Perception
# * Game
# * Infrastructures
# * Current player
#
module Madmass
  module Test

    class BuildAction < Madmass::Mechanics::Action
      action_params :initial_placement, :target
      action_states :play

      private

      # Preprocess parameters (see Action)
      def process_params
        @target = @parameters[:target]
      end

      # Checks action applicability (see Action)
      def applicable?

        unless Madmass.current_agent.action_applicable
          why_not_applicable.add(:'action.test_not_applicable', 'Agent cannot execute the build action')
          @message_builder.add_result({
              :message => :'action.test_not_applicable',
              :subs => {:type => 'build'},
              :level => 1
            })
        end

        return why_not_applicable.empty?
      end

      # Executes the action (see Action)
      def execute
        #Build the city
        Madmass.current_agent.executions += 1
      end

      # Builds the perception (see Action)
      def build_result
        # TODO: when perception builder will be implemented
      end

    end


  end
end