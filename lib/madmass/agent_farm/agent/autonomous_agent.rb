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
                stats = Madmass::AgentFarm::Agent::ExecutionStats.new

                queue.with_session(:tx => false) { |session|

                  #Set the appropriate behavior (as specified by agent implementation)
                  current_behavior = behavior
                  jms = jms_endpoint(session, queue)
                  #Register the agent to the domain
                  register_agent opts, jms

                  #################################
                  # Main loop.The transactions must be inside the while loop or it will be impossible to
                  # have access to the updated state of the action.
                  while alive
                    Madmass.logger.debug "Simulation opts are \n#{opts.to_yaml}\n"

                    tx_monitor do

                      #Execute a Simulation Step
                      alive = stats.measure lambda {

                        agent = fetch_agent opts

                        #Link Agent to Behavior and Stats
                        current_behavior.agent = stats.agent = agent
                        agent.behavior = current_behavior
                        Madmass.logger.debug "Linked Agent to Behavior and Stats"

                        #Execute Step
                        agent.execute_step(jms)

                        return (agent.status != 'dead')

                      }
                    end
                    Madmass.logger.debug "Agent alive: #{alive}"

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
              true #FIXME return something meaningful

            } #Thread end
          end

          private

          def register_agent opts, jms
            tx_monitor do
              agent = fetch_agent opts
              agent.execute({
                              :cmd => "madmass::action::remote",
                              :data => {
                                :cmd => 'actions::register_agent',
                                :sync => true,
                                :user => {:id => agent.oid}
                              }
                            }.merge(jms))
            end
          end

          def fetch_agent opts
            #Retreive current agent and set current behavior
            agent = nil
            begin
              agent = self.where_agent(opts)
              agent.execution_time ||= -1
            rescue Exception => ex
              # FIXME: it happens also with single node, there is a bug in the cloud-tm platform
              # If we cannot find the agent, we wait to see if we find it later
              # This may happen in a clustered environment if changes are not yet
              # propagated to all nodes.

              # FIXME: should not sleep in a tx
              Madmass.logger.warn("#{ex.message}\n ********* Retrying later ... *********")
              java.lang.Thread.sleep(opts[:step])
              retry
            end
            Madmass.logger.debug "Fetched Agent: #{agent.inspect}"
            agent
          end

        end

      end
    end
  end
end
