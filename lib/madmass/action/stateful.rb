# This module provides to the actions the capability to realize a workflow.
# The mechanism uses the Agent status to check action applicability and change its
# value when actions fires a status change.
module Madmass
  module Action
    module Stateful 

      def self.included base
        base.class_eval do
          class_attribute :applicable_states, :action_next_state
          self.action_next_state = nil
          self.applicable_states = []
          
          include InstanceMethods
          extend ClassMethods
        end
      end

      module InstanceMethods

        # Check if the current user state is allowed. Any is a special state that allow
        # every user state.
        def state_match?
          # without the current agent the flow don't exists
          return true unless Madmass.current_agent
          applicable_states.include?('any') or applicable_states.include?(Madmass.current_agent.status.to_s)
        end
       
        def applicable_states
          self.class.applicable_states
        end

        def action_next_state
          self.class.action_next_state
        end

        #        # FIXME: implement this coupled logic in gvision
        #        def change_state
        #          return unless User.current
        #          if action_next_state
        #            # if the next state is :end all users must change
        #            if action_next_state == :end
        #              Game.current.users.each do |user|
        #                next_state!(user)
        #              end
        #            else
        #              next_state!(User.current)
        #            end
        #          elsif(Game.current and Game.current.state == 'playing' and User.current.state != 'play')
        #            User.current.update_attribute(:state, 'play')
        #          end
        #        end

        def change_state
          return unless Madmass.current_agent
          next_state!(Madmass.current_agent) if action_next_state
        end

        
        # Set the next state to the user.
        def next_state!(agent)
          # FIXME: active record objects needs specific persistence invocation
          agent.status = action_next_state
        end
      end

      module ClassMethods

        # Use it in your subclasses to definethe states where your action is applicable (symbols or strings)
        def action_states(*states)
          self.applicable_states ||= []
          self.applicable_states += states.map(&:to_s)
        end

        # Use it in your subclasses to define the states where your action is applicable (symbols or strings)
        def next_state(state)
          self.action_next_state = state.to_s
        end

      end

    end
  end
end
