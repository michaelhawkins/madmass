###############################################################################
###############################################################################
#
# This file is part of MADMASS (MAssively Distributed Multi Agent System Simulator).
#
# Copyright (c) 2012 Algorithmica Srl
#
# MADMASS is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# MADMASS is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with MADMASS.  If not, see <http://www.gnu.org/licenses/>.
#
# Contact us via email at info@algorithmica.it or at
#
# Algorithmica Srl
# Vicolo di Sant'Agata 16
# 00153 Rome, Italy
#
###############################################################################
###############################################################################

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
          # without the current agent the flow doesn't exists
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
