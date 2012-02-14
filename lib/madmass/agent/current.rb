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

    # This is the Singleton class that holds the current agent instance.
    class CurrentAccessor
      #include Singleton
      attr_accessor :agent
    end

    # This module is used to provide a global access to the current agent executing the
    # action in all classes by invoking Madmass.current_agent.
    module Current
      def current_agent
        #Agent::CurrentAccessor.instance.agent
        @agent ||= Madmass::Agent::ProxyAgent.new
      end

      def current_agent=(agent)
        #Agent::CurrentAccessor.instance.agent = agent
        @agent = agent
      end
    end
  end

end
