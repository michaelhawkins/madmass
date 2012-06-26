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
  module Agent

    #The actions performed by this agent are executed in the background
    #FIXME use generator instead!

    #sync messaging reference => http://blog.bob.sh/2012/06/torquebox-making-message-processors.html

    class SyncJmsExecutor < TorqueBox::Messaging::MessageProcessor
      #include Madmass::Agent::Executor

      def initialize
        super
      end

      def on_message(body)
        Madmass.logger.debug "\n**************************SYNC Message received********************\n"
        # The synchronous methods always put the user message inside
        # a :message parameter, hence the need to descend here.
        Madmass.logger.debug "BODY:  \n #{body.to_yaml}\n"
        #json_message = JSON.parse(body) #body[:message] #FIXME is JSON needed?
        #Madmass.logger.debug "Objectified version of message received: #{json_message.to_yaml}"

        message_hash = JSON(body[:message])

        Madmass.logger.debug "MESSAGE \n #{message_hash.inspect}\n"

        Madmass.current_agent = Madmass::Agent::ProxyAgent.new(message_hash.delete('agent'))

        Madmass.current_agent.execute(message_hash)

        sync_reply(Madmass.current_perception)
      end

      def sync_reply(reply)
        Madmass.logger.debug "Reply perception is \n#{message.to_yaml}\n"
        queue_name = message.jms_message.jms_destination.name
        jms_message_id = message.jms_message.jms_message_id
        Madmass.logger.debug("sender queue_name #{queue_name}  and message_id #{jms_message_id}\n")
        queue = TorqueBox::Messaging::Queue.new(queue_name)

        queue.publish(reply, {
          :correlation_id => jms_message_id,
          :encoding => :json,
          :properties => {:perception => 'true'}}
        )
      end

    end
  end
end