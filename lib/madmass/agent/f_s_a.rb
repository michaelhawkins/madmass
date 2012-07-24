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

# To change this template, choose Tools | Templates
# and open the template in the editor.

module Madmass
  module Agent
    class FSA


      def current_state
        return self.status
      end

      def next_states

      end

      def transition

      end


      #######OLD STUFF############
      # Verify that che class that implements the agent has the required attributes.
      def allowed? args = nil
        # attribute id status required
        self.status
      rescue NoMethodError
        raise Madmass::Errors::WrongInputError, "#{self.class} must have the required attribute 'status'!"
      end

      def behavioral_validation action
        check_status
        unless action.state_match? or action.applicable_states.empty?
          raise Madmass::Errors::StateMismatchError, I18n.t(:'action.state_mistmatch',
                                                            {:agent_state => Madmass.current_agent.status,
                                                             :action_states => action.applicable_states.join(", ")})
        end
      end

    end
  end
end
