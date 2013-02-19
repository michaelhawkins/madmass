###############################################################################
###############################################################################
#
# This file is part of GeoGraph.
#
# Copyright (c) 2012 Algorithmica Srl
#
# GeoGraph is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# GeoGraph is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with GeoGraph.  If not, see <http://www.gnu.org/licenses/>.
#
# Contact us via email at info@algorithmica.it or at
#
# Algorithmica Srl
# Vicolo di Sant'Agata 16
# 00153 Rome, Italy
#
###############################################################################
###############################################################################


class Madmass::Transaction::CloudTmAdapter
  class << self
    def transaction &block
      Madmass.logger.debug "-- BEFORE Madmass::Transaction::CloudTmAdapter::transaction --"
      CloudTm::FenixFramework.getTransactionManager.withTransaction do
        Madmass.logger.debug "-- OPEN Madmass::Transaction::CloudTmAdapter::transaction --"
        block.call
        Madmass.logger.debug "-- EXECUTED Madmass::Transaction::CloudTmAdapter::transaction --"
      end
      Madmass.logger.debug "--  COMMITTED Madmass::Transaction::CloudTmAdapter::transaction --"
    end

    def rescues
      rescues = { Madmass::Errors::RollbackError => retry_proc } #HACK (NativeException -- it won't recognize RollbackErrors --)
      if defined?(Java::Org::Infinispan)
        rescues.merge!({ Java::OrgInfinispan::CacheException => retry_proc })
      end
      rescues
    end

    private


    def retry_proc
      Proc.new { |attempts|
        Madmass.logger.warn("Retrying transaction")
        #FIXME there should be a maximum number of attempts and a quadratic backoff
        sleep_time = (1000*rand/4.0)+ (attempts)**3 #polynomial backoff in ms
        Madmass.logger.warn("Sleeping for #{sleep_time}")
        java.lang.Thread.sleep(sleep_time)
        Madmass.logger.warn("Woke up after #{sleep_time}")
        :retry
      }
    end

  end
end
