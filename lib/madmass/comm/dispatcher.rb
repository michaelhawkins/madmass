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

# To change this template, choose Tools | Templates
# and open the template in the editor.

module Madmass
  module Comm

    # This module is in charge of dispatching perceptions (i.e., arrays of percepts)


    # This is the Singleton class that holds the Dispatcher instance.
    class DispatcherAccessor
      include Singleton

      def dispatch_percepts
        Madmass.logger.debug "Trying to dispatch #{Madmass.current_perception.inspect}"
        return unless Madmass.current_perception


        grouper = PerceptGrouper.new(Madmass.current_perception)

        Madmass.logger.debug "Sending to clients #{grouper.for_clients.inspect}"
        grouper.for_clients.each do |client, percepts|
          @sender.send(percepts, :client => client)
        end

        Madmass.logger.debug "Sending to topics #{grouper.for_topics.inspect}"
        grouper.for_topics.each do |topic, percepts|
          @sender.send(percepts, :topic => topic)
        end

      end

      def initialize
        class_name = Madmass.config.perception_sender.to_s.classify
        @sender = "#{class_name}".constantize
      rescue NameError => nerr
        msg = "Dispatcher: error when setting the sender: #{Madmass.config.perception_sender}, class #{class_name} don't exists!"
        Madmass.logger.error msg
        raise "#{msg} -- #{nerr.message}"
      end

      private



    end

    # This module is used to provide a global access to the percept dispatcher,
    # in all classes by invoking Madmass.send_percepts.
    module Dispatcher
      def dispatch_percepts
        Comm::DispatcherAccessor.instance.dispatch_percepts
      end
    end

  end
end
