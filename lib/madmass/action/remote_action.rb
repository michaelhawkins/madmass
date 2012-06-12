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
  module Action

    class RemoteAction < Madmass::Action::Action
      #include TorqueBox::Injectors
      action_params :data, :queue, :session, :producer, :jms_options
      #action_states :none
      #next_state :none

      def initialize params = {}
        super
      end

      def execute

        # Disable transactions because this method is invoked by a backgroundable method.
        # With transactions enabled all publish will send the data at the end of job operations.

        #######################################

        session = @parameters[:session]
        queue = @parameters[:queue]
        producer = @parameters[:producer]
        options = @parameters[:jms_options]

        unless queue
          @parameters[:data][:agent] = {:id => @parameters[:data][:agent].id}
          simple_execute
          return
        end

        @parameters[:data][:agent] = {:id => @parameters[:data][:agent].oid}

        payload = (@parameters[:data] || {}).to_json

        message = TorqueBox::Messaging::Message.new(session.instance_variable_get('@jms_session'), payload, options[:encoding])

        message.populate_message_headers(options)
        message.populate_message_properties(options[:properties])

        producer.disable_message_id = true
        producer.disable_message_timestamp = true

        producer.send(message.jms_message,
                      options.fetch(:delivery_mode, producer.delivery_mode),
                      options.fetch(:priority, producer.priority),
                      options.fetch(:ttl, producer.time_to_live))

      end

      def build_result
      end

      def remote?
        true
      end

      private

      #HACK FIXME
      def simple_execute
        Madmass.logger.warn("The current JMS publish is not reusing the session. You should see this message only once when setting the edge processor")

        set_connection_options
        queue = nil
        begin
          queue = TorqueBox::Messaging::Queue.new(Madmass.install_options(:commands_queue),
                                                  :host => @host,
                                                  :port => @port)

        rescue Exception => ex
          Madmass.logger.error "Exception opening remote commands queue: #{ex}"
          Madmass.logger.error ex.backtrace.join("\n")
        end
        # Disable transactions because this method is invoked by a backgroundable method.
        # With transactions enabled all publish will send the data at the end of job operations.
        @parameters[:data][:agent] = {:id => @parameters[:data][:agent].id}
        # Madmass.logger.debug "RemoteAction data: #{@parameters[:data].inspect}"
        #begin
        queue.publish((@parameters[:data] || {}).to_json, :tx => false, :persistent => false)
      end

      def set_connection_options
        if Madmass.install_options(:cluster_nodes) and Madmass.install_options(:cluster_nodes)[:geograph_nodes]
          # NOTE: it is available in Ruby 1.9, so if using an earlier version, require "backports".
          # Note that in Ruby 1.8.7 it exists under the unfortunate name choice; it was renamed in later version so you shouldn't use it.
          # In jruby sample does not exists!

          #FIXME: Geograph nodes should not be mentioned here! Refactor to  domain nodes ....
          @host = Madmass.install_options(:cluster_nodes)[:geograph_nodes].choice
          @port = Madmass.install_options(:remote_messaging_port)
        else
          @host = 'madmass-node'
          @port = 5445
        end
      end


    end

  end
end

