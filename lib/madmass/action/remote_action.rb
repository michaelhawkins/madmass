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
      action_params :data
      #action_states :none
      #next_state :none
      
      def initialize params = {}
        super
        @queue = TorqueBox::Messaging::Queue.new(Madmass.install_options(:commands_queue))
        @queue.connect_options = {
          :naming_host => Madmass.install_options(:naming_host),
          :naming_port => Madmass.install_options(:naming_port)
        }
      end

      def execute
        # Disable transactions because this method is invoked by a backgroundable method.
        # With transactions enabled all publish will send the data at the end of job operations.
        @parameters[:data][:agent] = {:id => @parameters[:data][:agent].id}
        Madmass.logger.debug "RemoteAction data: #{@parameters[:data].inspect}"
        @queue.publish((@parameters[:data] || {}).to_json, :tx => false)
        # notify that a remote command is sent
        ActiveSupport::Notifications.instrument("madmass.command_sent")
      end

      def build_result
      end

      def remote?
        true
      end
      
    end
    
  end
end

