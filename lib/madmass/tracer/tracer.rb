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

# This module contains the logic required to keep track of changes to the state of objects manipulated by actions.
# This is very useful when the client side of the application that use Madmass needs to read perceptions (response
# messages) in the right order (the receiving order can be different because of network's lags).
# This wants to be a simple interface for managing versions of objects.
# In order to be traced the class must invoke in the class context the method *trace*:
#   class SomeObject
#     trace
#   end
module Madmass
  module Tracer

    # Trace object changes.
    # Requires an array of instance attributes (*options*) that needs to be monitorated in order to activate
    # the trace mechanism.
    # The trace mechanism uses a special attribute called *version* and increments its value at
    # every change that occur in attributes inside *options* (the method argument).
    # FIXME: must permit to define tracer for new types (other than ActiveRecord, OgmModel and Object)
    # by classes defined out of the madmass gem.
    module Tracer
      def madmass_trace *options
        ancstrs = ancestors.map(&:to_s)
        if ancstrs.include?('ActiveRecord::Base')
          ar_trace options
        elsif ancstrs.include?('OgmModel')
          ogm_trace options
        else
          standard_trace options
        end
      end

      private

      # Simple ruby object trace implementation.
      # Define the version attribute and accessors for all attributes specified in the
      # *options* array. The setter for attributes in *options* increment the *version* value.
      def standard_trace options
        attr_reader :version

        options.each do |attr|
          attr_reader attr

          define_method "#{attr}=" do |value|
            instance_variable_set("@#{attr}", value)
            ver = instance_variable_get(:@version)
            ver ||= 0
            instance_variable_set(:@version, ver + 1)
          end
        end
      end

      # Active Record trace implementation.
      def ar_trace options
        set_locking_column :version
      end

      # Hibernate OGM trace implementation.
      def ogm_trace options

      end
    end
  end
end