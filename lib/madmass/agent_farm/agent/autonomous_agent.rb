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


            thread = Thread.new {
              perception = nil
              alive = true
              fails = 0


              while alive
                #The transaction must be inside the while loop or it will be impossible to
                #have access to the updated state of the action.
                #The tx is already opened in the controller, but this code is executed in a
                #message processor that is executed outside that transaction. TODO: Check if true.
                #Madmass.logger.debug "SIMULATE: Waiting to open CLOUD-TM transactions for #{opts.inspect}"
                #TorqueBox::transaction(:requires_new => true) do
                #Madmass.logger.debug "SIMULATE: Opened TORQUEBOX transaction for #{opts.inspect}"
                tx_monitor do
                 #Madmass.logger.debug "SIMULATE: Opened CLOUD-TM  transaction for #{opts.inspect}"
                  agent = self.where_agent(opts)
                  #Madmass.logger.debug "SIMULATE: Agent #{agent.inspect}"
                  if agent
                    agent.execute_step() if agent.running? #perception = execute_step(perception)
                    #Madmass.logger.debug "SIMULATE: Step executed by: #{agent.inspect}"
                    agent.status = 'dead' if agent.status == 'zombie'
                    alive = (agent.status != 'dead')
                    # agent.last_execution = java.util.Date.new
                  else
                    raise Madmass::Exception::CatastrophicError("SIMULATE: Agent #{opts} not found!")
                  end
                end
                #Madmass.logger.debug "SIMULATE: Closed CLOUD-TM  transaction for #{opts.inspect}"


                java.lang.Thread.sleep(opts[:step]);
              end
            }
            return true
          end

        end

        module InstanceMethods

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

          def set_behavior
            raise Madmass::Exception::CatastrophicError("set_behavior is an abstract method, please override it!")
          end

          def execute_step()
            #Madmass.logger.debug "SIMULATE: Executing step"

            if @current_behavior.nil?
              #Madmass.logger.debug "SIMULATE: about to set Behavior "
              set_behavior
              #Madmass.logger.debug "SIMULATE: Behavior #{@current_behavior.class.name} set "
            end

            unless @current_behavior.defined?
              @current_behavior.choose!
              #Madmass.logger.debug "SIMULATE: Current Behavior choosen "
            end

            next_action = @current_behavior.next_action
            #Madmass.logger.debug "SIMULATE: before execution #{next_action}"
            execute(next_action)
          end

          def running?
            #Madmass.logger.debug "SIMULATE: running?"
            return (self.status == 'running')
          end


        end

      end
    end
  end
end
