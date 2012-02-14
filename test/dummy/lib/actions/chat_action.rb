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


# This file is the implementation of the  ChatAction.
# The implementation must comply with the action definition pattern
# that is briefly described in the Madmass::Action::Action class.

  module Actions
    class ChatAction < Madmass::Action::Action
       action_params :message
       #action_states :none
       #next_state :none

     # [OPTIONAL]  Add your initialization code here.
     # def initialize params
     #   super
     #  # My initialization code
     # end


      # [MANDATORY] Override this method in your action to define
      # the action effects.
      def execute
        @message = @parameters[:message]
      end

      # [MANDATORY] Override this method in your action to define
      # the perception content.
      def build_result
        #Example
        p = Madmass::Perception::Percept.new(self)
        p.add_headers({:topics => 'all'}) #who must receive the percept
        p.data =  {:message => @message}
        Madmass.current_perception << p
      end

      # [OPTIONAL] - The default implementation returns always true
      # Override this method in your action to define when the action is
      # applicable (i.e. to verify the action preconditions).
      # def applicable?
      #
      #   if CONDITION
      #     why_not_applicable.add(:'DESCR_SYMB', 'EXPLANATION')
      #   end
      #
      #   return why_not_applicable.empty?
      # end

      # [OPTIONAL] Override this method to add parameters preprocessing code
      # The parameters can be found in the @parameters hash
      # def process_params
      #   puts "Implement me!"
      # end

    end

  end
