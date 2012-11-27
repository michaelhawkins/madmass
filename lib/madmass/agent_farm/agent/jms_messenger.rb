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
      module JmsMessenger

        module ClassMethods

          #returns the commands queue
          def commands_queue
            queue_opts = host_and_port
            Madmass.logger.debug "Creating queue: #{Madmass.install_options(:commands_queue)}, with opts #{queue_opts.inspect}"
            queue = TorqueBox::Messaging::Queue.new(Madmass.install_options(:commands_queue), queue_opts)
            Madmass.logger.debug "Queue created: #{queue.inspect}"
            queue
          end

          #Retreive current agent and set current behavior
          def prepare_agent opts
            current_behavior = nil
            agent = nil
            tx_monitor do
              current_behavior = behavior
              agent = self.find_by_id(opts)
              unless agent
                Madmass.logger.warn("\n ********* Agent not found: Retrying later for #{opts.inspect}... *********")
                raise Madmass::Errors::RollbackError.new("Error while fetching agent: #{opts.inspect}")
              end
              agent.execution_time = -1
            end
            Madmass.logger.debug "Agent: #{agent.inspect} with behavior #{current_behavior.inspect}"
            return current_behavior
          end


          # @param [Object] session
          # @param [Object] queue
          def jms_endpoint(session, queue)
            destination = queue
            options = queue.normalize_options(:persistent => false)

            producer = session.instance_variable_get('@jms_session').create_producer(
              session.java_destination(destination))
            #Madmass.logger.debug "Getting behavior"

            Madmass.logger.debug "In session #{session.inspect}, using producer #{producer.inspect}"

            #return jms data
            {
              :jms => {:queue => queue,
                       :session => session,
                       :producer => producer,
                       :jms_options => options}
            }
          end


          def host_and_port
            opts = {}

            if Madmass.install_options(:cluster_nodes) and Madmass.install_options(:cluster_nodes)[:geograph_nodes]
              #FIXME: Geograph nodes should not be mentioned here! Refactor to  domain nodes ....
              opts[:host] = Madmass.install_options(:cluster_nodes)[:geograph_nodes].sample
              opts[:port] = Madmass.install_options(:remote_messaging_port)
            else
              opts[:host] = 'madmass-node'
              opts[:port] = 5445
            end
            opts
          end


        end
      end
    end
  end
end
