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
    #*NOTE* requires Torquebox 2
    #FIXME use generator instead!

    class JmsExecutor < TorqueBox::Messaging::MessageProcessor
      #include Madmass::Agent::Executor

      def initialize
        super
      end

      def on_message(body)
        # notify that a command is received
        ActiveSupport::Notifications.instrument("madmass.command_received")

        # The body will be of whatever type was published by the Producer
        # the entire JMS message is available as a member variable called message()
        #code = execute(body)
        #raise "action did not succeed" unless code == 'ok'
        #agent = Madmass.current_agent || ProxyAgent.new
        message = JSON(body)
        Madmass.current_agent = Madmass::Agent::ProxyAgent.new(message.delete('agent'))

        #Exit the (messagging) transactional context by launching a new thread
        #or you could have duplicate perceptions when rollbacking
        #Access to data is already transactional in the execute method;
        Thread.new{Madmass.current_agent.execute(message)}
      end
    end
  end
end