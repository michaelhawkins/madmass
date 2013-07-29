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


module Madmass
  module AgentFarm
    module Agent
      class ExecutionStats
        include Madmass::Transaction::TxMonitor
        attr_accessor :agent
        LOGGING_INTERVAL = 5 #sec

        def initialize
          @last_iteration_update = Time.now.ago(LOGGING_INTERVAL+1)
          @iteration_start_time = nil
        end


        def measure step

          @iteration_start_time = Time.now

          alive = step.call #Execute a Simulation Step

          # sample the time it takes for the agent to execute a step (in ms)
          if (Time.now-@last_iteration_update) > LOGGING_INTERVAL
            @agent.execution_time = (Time.now - @iteration_start_time)*1000
            Madmass.logger.debug "Updated exec duration to #{@agent.execution_time}"
            @last_iteration_update = Time.now
          end

          alive
        end


      end

    end
  end
end
