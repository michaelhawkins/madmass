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

#require Madmass::AgentFarm::Agent::Behavior

module Madmass
  module AgentFarm
    module Agent
      #To control the agents
      module Controllable


        #Shuts down the simulation
        def shutdown
          self.status = 'zombie'
        end

        def play
          self.status = 'running'
        end

        def stop
          self.status = 'stopped'
        end

        def pause
          self.status = 'paused'
        end


        # @param [Madmass::AgentFarm::Agent::Behavior] my_behavior
        def behavior= my_behavior
          @current_behavior = my_behavior
        end

        def execute_step(opts)
t = Time.now
          unless @current_behavior
            Madmass.logger.debug "SIMULATE: about to set Behavior "
            raise Madmass::Errors::CatastrophicError.new "Did not find behavior! "
          end

          unless @current_behavior.defined?
            @current_behavior.choose!
            Madmass.logger.debug "SIMULATE: Current Behavior choosen "
          end

          to_kill = false
          #Exectue a step if the agent is running
          if self.status == 'zombie'
            next_action = @current_behavior.last_wish
            to_kill = true
            Madmass.logger.debug "Agent killed"
          else
            #Note: results (if any) are in Madmass.current_perception
            next_action = @current_behavior.next_action
          end
Madmass.logger.error "[MADMASS 1] #{(Time.now - t)}s"
t = Time.now 
         if next_action != nil
            next_action.merge!(opts)

            Madmass.logger.debug "SIMULATE: will execute \n #{next_action.inspect}"
            self.execute(next_action)  if self.running?
         end
Madmass.logger.error "[MADMASS 2] #{(Time.now - t)}s"          
          self.status = 'dead' if to_kill

          Madmass.logger.debug "***********************************************"
          Madmass.logger.debug "SIMULATE: Executed \n\t #{next_action.inspect}\n\t"
          Madmass.logger.debug "***********************************************"
        end

        # @return [Madmass::AgentFarm::Agent::Behavior]
        def behavior
          raise Madmass::Errors::CatastrophicError.new("behavior is an abstract method, please override it!")
        end


        def running?
          #Madmass.logger.debug "SIMULATE: running?"
          (self.status == 'running' || self.status == 'zombie')
        end

      end

    end
  end
end
