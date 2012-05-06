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
      module AutonomousAgent
        include Madmass::Agent::Executor
        include Madmass::Transaction::TxMonitor

        def self.included(base)
          base.send(:include, InstanceMethods)
        end

        module InstanceMethods
          include TorqueBox::Messaging::Backgroundable
          always_background :simulate


          #TODO: set_plan plan #e.g. override in geograph_agent-farm with set_plan ({:type=> gpx, :data =>path/to/data)


          #To control the agents

          # Launches an autonomous agent simulation
          def boot delay
            init_status
            simulate delay
          end

          #Shuts down the simulation
          def shutdown
            monitor { self.status = 'zombie' }
          end

          def play
            monitor { self.status = 'running' }
          end

          def stop
            monitor { self.status = 'stopped' }
          end

          def pause
            monitor { self.status = 'paused' }
          end

          private

          def execute_step(options = {:force => false})
            #FIXME: remove?  init_status if options[:force]
            action = choose_action
            #persist_last_action action
            execute(action)

          rescue Exception => ex
            on_error(ex)
          end

          #Simulates the agent at a given step (in seconds)
          def simulate step
            perception = nil
            alive = true
            while alive
              #The transaction must be inside the while loop or it will be impossible to
              #have access to the updated state of the action.
              #The tx is already opened in the controller, but this code is executed in a
              #message processor that is executed outside that transaction. TODO: Check if true.
              tx_monitor do
                execute_step() if running? #perception = execute_step(perception)
                Madmass.logger.info "agent -- type: #{self.type}  -- state: #{self.status} -- id: #{self.oid}"
                self.status = 'dead' if self.status == 'zombie'
                alive = (self.status != 'dead')
              end
              java.lang.Thread.sleep(step*1000);
            end
            #TODO Destroy Agent
          end

          def init_status
            monitor { self.status = 'stopped' }
          end

          #def persist_last_action action
          #  self.status = 'running'
          #  self.perception_status = action[:perception_status]
          #end

          #def completed?
          #  return true unless perception_status
          #  return (with_success? or with_failure?)
          #end

          #def with_success?
          #  perception_status == 'ok'
          #end
          #
          #def with_failure?
          #  perception_status == 'precondition_failed'
          #end

          def running?
            #return true unless perception_status
            return (self.status == 'running')
          end


          #TODO is this needed?
          def monitor &block

            new_state = block.call

            Madmass.logger.info("Setting new state #{new_state} for #{self.oid}")
          rescue Exception => ex
            @pause_retry ||= 1
            if @pause_retry >= 10
              Madmass.logger.error "Max retries for pause reached (10) - exception was: #{ex}"
              return
            end
            Madmass.logger.error "Retry #{@pause_retry} for pause reached (10) - exception was: #{ex}"
            @pause_retry += 1
            sleep(rand/4.0)
            retry
          end
        end

      end
    end
  end
end
