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
      MAX_ATTEMPTS = 20 #FIXME must be configurable

      def tx_monitor &block
        Madmass.logger.debug "############################# TX_MONITOR START #############################"
        attempts = 0

        begin
          Madmass.transaction do
            block.call
            #raise Java::OrgInfinispan::CacheException.new #REMOVE ME (USED ONLY FOR DEBUGGING)
          end
        rescue Exception => exc
          Madmass.logger.warn "\n********************************************************\n"
          Madmass.logger.warn "Exception in transaction"
          Madmass.logger.warn("Error during processing: #{$!}, message \n #{exc.message}")
          Madmass.logger.warn("Backtrace:\n\t#{exc.backtrace.join("\n\t")}")
          Madmass.logger.warn "Cause: \n\t#{exc.cause.backtrace.join("\n\t")}" if exc.cause
          Madmass.logger.warn "\n********************************************************\n\n\n"
          cause = main_cause exc
          Madmass.logger.warn "Main Cause is #{cause}"
          policy = Madmass.rescues[cause.class]
          # do not retry when the action is not applicable
          Madmass.logger.error "CAUSE CLASS: #{cause.class}"
          if policy 
            Madmass.logger.warn("Recovering through policy for #{cause.class}")
            if policy.call(attempts) == :retry
              attempts += 1
              Madmass.logger.warn("Retrying for the **#{ActiveSupport::Inflector.ordinalize(attempts)}** time!")
              retry if attempts <= MAX_ATTEMPTS
              msg = "Aborting, max number of retries (#{MAX_ATTEMPTS}) reached"
              Madmass.logger.error msg
              raise Madmass::Errors::CatastrophicError.new(msg)
            end
          else
            Madmass.logger.error("Raising up the stack! No recovery policy for: #{cause.class} ** MESSAGE:\n #{cause.message} ")
            raise exc;
          end
        end
        Madmass.logger.debug "############################# TX_MONITOR END #############################"
      end

      private

      def main_cause exc
        main_causes_class = [Madmass::Errors::RollbackError]
        main_causes_class << Java::OrgInfinispan::CacheException if defined?(Java::Org::Infinispan)
        current = exc
        while current
          Madmass.logger.warn("======== Inspecting exception: #{current.class.name}")
          Madmass.logger.warn("Message \n #{current.message}")
          Madmass.logger.warn("Backtrace:\n\t#{current.backtrace.join("\n\t")}")
          return current if main_causes_class.detect() { |c| c.class.name == current.class.name }
          current = current.class.method_defined?(:cause) ? current.cause : nil
        end
        return exc
      end
    end
  end
end
