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
          base.send(:include, InstanceMethods)
        end

        module ClassMethods

          # Simulates the agent at a given step (in seconds)
          def simulate(opts)
            # initialize agent status

            #Madmass.logger.error "PUT BACK THE Thread!"
            thread = Thread.new {
              begin

                perception = nil
                alive = true
                fails = 0

                #@parameters[:data][:agent] = {:id => @parameters[:data][:agent].oid}
                queue_opts = host_and_port

                queue =nil;
                min_logging_interval = 5 #5sec

                queue = TorqueBox::Messaging::Queue.new(Madmass.install_options(:commands_queue), queue_opts)


                queue.with_session(:tx => false) { |session|
                  destination = queue
                  options = queue.normalize_options(:persistent => false)

                  producer = session.instance_variable_get('@jms_session').create_producer(
                    session.java_destination(destination))
                  #Madmass.logger.debug "Getting behavior"

                  current_behavior = nil

                  begin
                    tx_monitor do
                      current_behavior = behavior
                      agent = self.where_agent(opts)
                      agent.execution_time = -1
                    end
                  rescue Exception => ex
                    Madmass.logger.warn("error retriving agent #{ex.message}. Retrying ...")
                    java.lang.Thread.sleep(opts[:step])
                    retry
                  end

                  last_iteration_update = Time.now

                  #Madmass.logger.debug "Got behavior #{current_behavior.inspect}"
                  while alive
                    #The transaction must be inside the while loop or it will be impossible to
                    #have access to the updated state of the action.
                    #The tx is already opened in the controller, but this code is executed in a
                    #message processor that is executed outside that transaction. TODO: Check if true.
                    iteration_start_time = Time.now
                    tx_monitor do
                      agent = self.where_agent(opts)
                      unless agent
                        Madmass.logger.warn "Agent #{opts.inspect} not found. Retrying later .."
                        java.lang.Thread.sleep(opts[:step])
                        next
                      end
                      if agent
                        current_behavior.agent = agent
                        agent.behavior = current_behavior

                        jms_opts = {:queue => queue,
                                    :session => session,
                                    :producer => producer,
                                    :jms_options => options}
                        agent.execute_step(jms_opts) if agent.running? #perception = execute_step(perception)
                                                                       #Madmass.logger.debug "SIMULATE: Step executed by: #{agent.inspect}"
                        agent.status = 'dead' if agent.status == 'zombie'
                        alive = (agent.status != 'dead')
                      else
                        raise Madmass::Errors::CatastrophicError.new("SIMULATE: Agent #{opts} not found!")
                      end
                    end

                    #we sample the time it takes for the agent to execute a step (in ms)
                    if ((iteration_start_time-last_iteration_update) > min_logging_interval)
                      tx_monitor do
                        agent = self.where_agent(opts)
                        if agent
                          agent.execution_time = (Time.now- iteration_start_time)*1000
                        else
                          raise Madmass::Errors::CatastrophicError.new("SIMULATE: Agent #{opts} not found!")
                        end
                        # Madmass.logger.info "Updated exec duration to #{agent.execution_time}"
                      end
                      last_iteration_update = Time.now
                      #else
                      #Madmass.logger.info "Skipping exec duration update"
                      #Madmass.logger.info "Iteration Start Time #{iteration_start_time}"
                      #Madmass.logger.info "Last Update #{last_iteration_update}"
                      #Madmass.logger.info "Elapsed #{(iteration_start_time-last_iteration_update)}"
                    end
                    sleep_time = opts[:step]+((opts[:step]/3)*(0.5-rand))
                    java.lang.Thread.sleep(sleep_time)
                  end
                }
              rescue Exception => ex
                Madmass.logger.error "AGENT ABORTED due to:  #{ex}"
                Madmass.logger.error ex.backtrace.join("\n")
                Madmass.logger.error ex.backtrace.join("\n")
                Madmass.logger.error "cause #{ex.cause.backtrace.join("\n")}" if ex.cause
                return false
              end
            }

            return true #FIXME return something meaningful
          end

          def behavior
            raise Madmass::Errors::CatastrophicError.new("behavior is an abstract method, please override it!")
          end


          def update_cycle_stats

          end

          def host_and_port
            opts = {}

            if (Madmass.install_options(:cluster_nodes) and Madmass.install_options(:cluster_nodes)[:geograph_nodes])
              # NOTE: sample is available in Ruby 1.9, so if using an earlier version, require "backports".
              # Note that in Ruby 1.8.7 it exists under the unfortunate name choice; it was renamed in later version so you shouldn't use it.
              # In jruby sample does not exists!
              #FIXME: Geograph nodes should not be mentioned here! Refactor to  domain nodes ....
              opts[:host] = Madmass.install_options(:cluster_nodes)[:geograph_nodes].choice
              opts[:port] = Madmass.install_options(:remote_messaging_port)
            else
              opts[:host] = 'madmass-node'
              opts[:port] = 5445
            end
            return opts
          end

        end

        module InstanceMethods

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


          def behavior= behavior
            @current_behavior = behavior
          end

          def execute_step(opts)
            #Madmass.logger.debug "SIMULATE: Executing step"

            unless @current_behavior
              #Madmass.logger.debug "SIMULATE: about to set Behavior "
              raise Madmass::Errors::CatastrophicError.new "Did not find behavior! "
            end

            unless @current_behavior.defined?
              @current_behavior.choose!
              #Madmass.logger.debug "SIMULATE: Current Behavior choosen "
            end

            next_action = @current_behavior.next_action
            next_action.merge!(opts)
            #Madmass.logger.debug "SIMULATE: before execution #{next_action.inspect}"
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
