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
                stats = Madmass::AgentFarm::Agent::ExecutionStats.new

                current_behavior = behavior
                current_behavior.opts = opts
                if current_behavior.respond_to?(:get_additional_opts)
                  opts = opts.merge(current_behavior.get_additional_opts)
                end
Madmass.logger.error "FARM REGISTERING AGENT: #{opts}"
                register_agent opts	# jms

                while alive
                  Madmass.logger.debug "Simulation opts are \n#{opts.to_yaml}\n"

                  tx_monitor do

                    alive = stats.measure lambda {

                      agent = fetch_agent opts

                      #Link Agent to Behavior and Stats
                      current_behavior.agent = stats.agent = agent
                      agent.behavior = current_behavior
                      Madmass.logger.debug "Linked Agent to Behavior and Stats"

                      #Execute Step
Madmass.logger.error "MADMASS A #{opts[:agent_id]}"
t = Time.new
                      agent.execute_step({})		# jms
Madmass.logger.error "MADMASS B #{opts[:agent_id]} #{(Time.new - t).to_f}"

                      return (agent.status != 'dead')

                    }
                  end
                  Madmass.logger.debug "Agent alive: #{alive}"

                  # sleep before the next step, with some noise to avoid
                  # many "synchronized" requests when you start multiple agents together
                  sleep_time = opts[:step]+((opts[:step]/3.0)*(0.5-rand))
Madmass.logger.error "MADMASS C #{opts[:agent_id]} #{sleep_time}"
                  java.lang.Thread.sleep(sleep_time)

                end

              rescue Exception => ex
                Madmass.logger.error "AGENT ABORTED"
                Madmass.logger.error("Error during processing: #{$!}, message \n #{ex.message}")
                Madmass.logger.error("Backtrace:\n\t#{ex.backtrace.join("\n\t")}")
                Madmass.logger.error "CAUSE \n\t#{ex.cause.backtrace.join("\n\t")}" if ex.cause
                return false

              end
              true #FIXME return something meaningful

            } #Thread end
            true #to avoid error on marshaling threads
          end

          private

          def register_agent opts
            tx_monitor do
              agent = fetch_agent opts
              agent.execute({
                              :cmd => "madmass::action::remote",
                              :data => {
                                :cmd => 'register_agent',
                                :sync => true,
                                :user => {:id => agent.getExternalId},
                                :data => {:type => agent.class.name.demodulize, :locality_hint => opts[:locality_hint]}
                              }
                            })
            end
          end

          def fetch_agent opts
            #Retreive current agent and set current behavior
            agent = nil
            begin
              agent = self.find_by_id(opts)
              unless agent
                Madmass.logger.warn("\n ********* Agent not found: Retrying later for #{opts.inspect}... *********")
                raise Madmass::Errors::RollbackError.new("Error while fetching agent: #{opts.inspect}")
              end
              agent.execution_time ||= -1

              Madmass.logger.debug "Fetched Agent: #{agent.inspect}"
              agent
            end

          end

        end
      end
    end
  end
end
