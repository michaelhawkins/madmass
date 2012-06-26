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
  module Perception

    # This is the Singleton class that holds the current perception instance.
    class CurrentAccessor
      #include Singleton
      attr_accessor :perception
    end

    # This module is used to provide a global access to the current perception, of the
    # action in execution, in all classes by invoking Madmass.current_perception.
    module Current
      def current_perception
        #Perception::CurrentAccessor.instance.perception #HACK TODO in a better way
        #Perception::CurrentAccessor.perception #HACK TODO in a better way
        @percept ||= Madmass::Perception::Percept.new
      end

      def current_perception=(perception)
        #Perception::CurrentAccessor.instance.perception = perception
        @percept = perception
      end
    end

  end
end
