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
        #include Madmass::Transaction::TxMonitor

        def self.included(base)
          base.extend ClassMethods
          base.extend(Madmass::Transaction::TxMonitor)
          base.extend(TorqueBox::Messaging::Backgroundable)
          base.send(:include, InstanceMethods)
        end

        module ClassMethods

          # Simulates the agent at a given step (in seconds)
          def simulate(opts)
            # initialize agent status
            Madmass.logger.info("Simulating with params #{opts.inspect}")
            tx_monitor do
              ##FIXME
              my_manager = CloudTm::TxSystem.getManager
              root = my_manager.getRoot
              Madmass.logger.info("Root #{root.oid}")
              groups = root.getAgentGroups
              Madmass.logger.info("Groups #{groups.map(&:inspect)}")

              agent = CloudTm::Agent.where_agent(opts)
              Madmass.logger.warn("Agent not found, All agents are: #{CloudTm::Agent.all_agents(opts).map(&:inspect)}") unless agent
              agent.status = 'stopped'
            end

            perception = nil
            alive = true
            while alive
              #The transaction must be inside the while loop or it will be impossible to
              #have access to the updated state of the action.
              #The tx is already opened in the controller, but this code is executed in a
              #message processor that is executed outside that transaction. TODO: Check if true.
              tx_monitor do
                agent = self.where_agent(opts)
                #Madmass.logger.info "Simulate found: #{agent.inspect}"
                #FIXME agent.execute_step() if agent.running? #perception = execute_step(perception)
                Madmass.logger.info "Step executed by: #{agent.inspect}"
                agent.status = 'dead' if agent.status == 'zombie'
                alive = (agent.status != 'dead')
              end


              java.lang.Thread.sleep(opts[:step]*1000);
            end
            #TODO Destroy Agent
          end

        end

        module InstanceMethods
          #include TorqueBox::Messaging::Backgroundable
          #always_background :simulate


          #TODO: set_plan plan #e.g. override in geograph_agent-farm with set_plan ({:type=> gpx, :data =>path/to/data)


          #To control the agents

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


          def execute_step(options = {:force => false})
            #FIXME: remove?  init_status if options[:force]
            action = choose_action
            #persist_last_action action
            execute(action)

          rescue Exception => ex
            on_error(ex)
          end

          def running?
            #return true unless perception_status
            return (self.status == 'running')
          end


        end

      end
    end
  end
end
