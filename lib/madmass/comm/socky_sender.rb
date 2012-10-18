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
  module Comm

    class SockySender
      include Singleton

      class << self
        def send(percepts, opts)
          # push messages to HTML clients via socky
          Socky.send(percepts.to_json.html_safe, opts)
          Madmass.logger.debug "SENDING PERCEPTION WITH OPTS: #{opts.inspect}"

          # push messages to JMS clients via stomplet
          #FIXME
          if defined?(TorqueBox::Messaging)
            begin
              topic.publish(JSON(percepts), :properties => opts)
            rescue Exception => ex
              Madmass.logger.error ex
            end
          end

        end

        private

        def topic
          # FIXME: move destination name in Madmass.config
          @topic ||= TorqueBox::Messaging::Topic.new('/topic/perceptions')
        end

      end

    end

  end
end

