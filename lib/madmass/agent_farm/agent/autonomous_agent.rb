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

        def self.included(base)
          base.extend ClassMethods
          base.extend(Madmass::Transaction::TxMonitor)
          base.extend(TorqueBox::Messaging::Backgroundable)
          base.extend(Madmass::AgentFarm::Agent::JmsMessenger::ClassMethods)
          base.send(:include, Madmass::AgentFarm::Agent::Controllable)
        end

        module ClassMethods

          # Simulates the autonomous agent
          # @param [HashWithIndifferentAccess] opts
          def simulate(opts)

            Madmass.logger.info "Starting new agent: #{opts.inspect}"

            #Start new thread to detactch from messagging transactional
            #context. Messaging is used to load balance agent creation
            Thread.new {
              begin
                alive = true

                queue = commands_queue

                queue.with_session(:tx => false) { |session|

                  current_behavior = prepare_agent opts
                  last_iteration_update = Time.now

                  ##################################
                  # Main loop
                  #################################
                  #The transactions must be inside the while loop or it will be impossible to
                  #have access to the updated state of the action.

                  while alive

                    iteration_start_time = Time.now

                    #Execute a Simulation Step
                    simulate_step current_behavior, opts, :session => session, :queue => queue

                    # sample the time it takes for the agent to execute a step (in ms)
                    last_iteration_update = Time.now if update_exec_stats(iteration_start_time, last_iteration_update, opts)

                    # sleep before the next step, with some noise to avoid
                    # many "synchronized" requests when you start multiple agents together
                    sleep_time = opts[:step]+((opts[:step]/3)*(0.5-rand))
                    java.lang.Thread.sleep(sleep_time)
                  end
                }
              rescue Exception => ex
                Madmass.logger.error "AGENT ABORTED"
                Madmass.logger.error("Error during processing: #{$!}, message \n #{ex.message}")
                Madmass.logger.debug("Backtrace:\n\t#{ex.backtrace.join("\n\t")}")
                Madmass.logger.error "CAUSE \n\t#{ex.cause.backtrace.join("\n\t")}" if ex.cause
                return false
              end
            }

            true #FIXME return something meaningful
          end


          private
          # @param [Time] iteration_start_time
          # @param [Time] last_iteration_update
          # @param [HashWithIndifferentAccess] opts
          def update_exec_stats(iteration_start_time, last_iteration_update, opts)

            logging_interval = 5 #5sec

            if (iteration_start_time-last_iteration_update) > logging_interval
              tx_monitor do
                agent = self.where_agent(opts)
                if agent
                  agent.execution_time = (Time.now - iteration_start_time)*1000
                else
                  msg = "SIMULATE: Agent #{opts.inspect} not found!"
                  Madmass.logger.error msg
                  raise Madmass::Errors::CatastrophicError.new(msg)
                end
                Madmass.logger.debug "Updated exec duration to #{agent.execution_time}"
              end
              return true
            end
            return false

          end


          def prepare_agent opts
            #Retreive current agent and set current behavior
            current_behavior = nil
            agent = nil
            begin
              tx_monitor do
                current_behavior = behavior
                agent = self.where_agent(opts)
                agent.execution_time = -1
              end
            rescue Exception => ex
              Madmass.logger.warn("#{ex.message}\n ********* Retrying later ... *********")
              java.lang.Thread.sleep(opts[:step])
              retry
            end
            Madmass.logger.debug "Agent: #{agent.inspect} with behavior #{current_behavior.inspect}"
            return current_behavior
          end

          def simulate_step current_behavior, opts, jms
            Madmass.logger.debug "Simulation opts are \n#{opts.to_yaml}\n"

            tx_monitor do

              #Look for agent
              agent = self.where_agent(opts)
              # If we cannot find the agent, we wait to see if we find it later
              # This may happen in a clustered environment if changes are not yet
              # propagated to all nodes.
              # FIXME: it happens also with single node, there is a bug in the cloud-tm platform
              # FIXME: should not sleep in a tx
              unless agent
                Madmass.logger.warn "Agent #{opts.inspect} not found. Retrying later .."
                java.lang.Thread.sleep(opts[:step])
                next
              end

              #Execute a simulation step
              if agent
                current_behavior.agent = agent
                agent.behavior = current_behavior

                #Exectue a step if agent running
                #Percept is in Madmass.current_perception (if any)
                agent.execute_step(jms_endpoint(jms[:session], jms[:queue])) if agent.running?
                Madmass.logger.debug "SIMULATE: Step executed by: #{agent.inspect}"

                #Check if agent has been killed
                #FIXME: give the possibility to perform a last action if
                #between zombie and dead state
                agent.status = 'dead' if agent.status == 'zombie'
                alive = (agent.status != 'dead')
              else
                raise Madmass::Errors::CatastrophicError.new("SIMULATE: Agent #{opts} not found!")
              end

            end

          end
        end
      end
    end
  end
end
