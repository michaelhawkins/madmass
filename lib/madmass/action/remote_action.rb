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
      action_params :data, :jms, :sync
      #action_states :none
      #next_state :none

      def initialize params = {}
        super
        @jms = @parameters.delete(:jms)
        if @jms
          @session = @jms[:session]
          @queue = @jms[:queue]
          @producer = @jms[:producer]
          @options = @jms[:jms_options]
        end
        @sync = @parameters[:data].delete(:sync)
        #@parameters[:data][:agent] = {:id => @parameters[:data][:agent].oid}
        @payload = (@parameters[:data] || {})
        Madmass.logger.debug %Q{Initialized Remote action with payload:\n #{@payload.to_yaml}\n}
        @remote_perception = []
      end

      def execute

        @remote_perception = []
        #FIXME: HACK for set edge processor action
        unless @jms
          simple_execute
          return
        end

        if @sync
          Madmass.logger.debug "Sync send mode"
          @remote_perception = sync_send
          Madmass.logger.debug "Response was \n#{@remote_perception.to_yaml}\n"
        else
          Madmass.logger.debug "Async send mode"
          async_send
          @remote_perception = []
          Madmass.logger.debug "Message sent"
        end


      end

      def build_result
        @remote_perception.each do |p|
          percept = Madmass::Perception::Percept.new(self)
          percept.data = p.data
          Madmass.current_perception << percept
        end
        Madmass.logger.debug "Generated Perception \n#{Madmass.current_perception.to_yaml}\n"
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
        @parameters[:data][:agent] = {:id => @parameters[:data][:agent].object_id}
        Madmass.logger.debug "RemoteAction data: #{@parameters[:data].to_yaml}"
        #begin
        queue.publish((@parameters[:data] || {}), :tx => false, :persistent => false)
      end

      def sync_send
        Madmass.logger.debug "SYNC SEND: JMS options #{@options.to_yaml}"
        Madmass.logger.debug "SYNC SEND: JMS payload #{@payload.to_yaml}"

        result = @session.publish_and_receive(@queue,
                                            @payload,
                                            { :timeout => 60000, :tx => false} #WHICH ENCODING? :encoding => :json,
        )
        return (result or [])
      end

      def async_send

        @message = TorqueBox::Messaging::Message.new(@session.instance_variable_get('@jms_session'), @payload, @options[:encoding])

        @message.populate_message_headers(@options)

        Madmass.logger.debug "Message properties of async send are: #{@options[:properties].to_yaml} "
        @message.populate_message_properties(@options[:properties])

        @producer.disable_message_id = true
        @producer.disable_message_timestamp = true

        @producer.send(@message.jms_message,
                       @options.fetch(:delivery_mode, @producer.delivery_mode),
                       @options.fetch(:priority, @producer.priority),
                       @options.fetch(:ttl, @producer.time_to_live))
        nil

      end

      #FIXME rename geograph_nodes in domain_nodes and remove dependency from nimbus
      def set_connection_options
        if Madmass.install_options(:cluster_nodes) and Madmass.install_options(:cluster_nodes)[:geograph_nodes]
          #FIXME: Geograph nodes should not be mentioned here! Refactor to  domain nodes ....
          @host = Madmass.install_options(:cluster_nodes)[:geograph_nodes].sample
          @port = Madmass.install_options(:remote_messaging_port)
          Rails.logger.info("Connecting to remote backend/domain at host #{@host}:#{@port}")
        else
          @host = 'madmass-node'
          @port = 5445
          Rails.logger.info("Connecting to local backend/domain at host #{@host}:#{@port}")
        end
      end
    end

  end
end

