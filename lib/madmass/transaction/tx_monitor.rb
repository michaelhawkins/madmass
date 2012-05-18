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
  module Transaction
    module TxMonitor
      MAX_ATTEMPTS =10 #FIXME must be configurable

      def tx_monitor &block
        attempts = 0

        begin
          Madmass.transaction do
            block.call
            #raise Java::OrgInfinispan::CacheException.new #REMOVE ME FOR DEBUGGING
          end
        rescue Exception => exc
          cause = main_cause exc
          policy = Madmass.rescues[cause.class]
          if Madmass.rescues[cause.class]
            Madmass.logger.warn("Recovering through policy for #{cause.class}")
            if policy.call(attempts) == :retry
              attempts += 1
              Madmass.logger.warn("Retrying for the **#{ActiveSupport::Inflector.ordinalize(attempts)}** time!")
              retry if attempts <= MAX_ATTEMPTS
              Madmass.logger.error "Aborting, max number of retries (#{MAX_ATTEMPTS}) reached"

            end
          else
            Madmass.logger.error("Raising up the stack! No recovery policy for: #{cause.class} ** MESSAGE:\n #{cause.message} ")
            raise exc;
          end
        end
      end

      private
      def main_cause exc
        main_causes_class = [Java::OrgInfinispan::CacheException]
        current = exc
        while current
          Madmass.logger.warn("Inspecting exception: #{current.class} --  #{current.message}")
          return current if main_causes_class.detect() { |c| c == current.class }
          current =  current.class.method_defined?(:cause) ? current.cause : nil
        end
        return exc
      end
    end
  end
end
