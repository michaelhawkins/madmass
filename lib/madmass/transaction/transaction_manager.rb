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

require 'forwardable'

module Madmass
  module Transaction

    def transaction &block
      Madmass::Transaction::TransactionManager.instance.transaction do
        block.call
      end
    end

    def rescues
      Madmass::Transaction::TransactionManager.instance.rescues
    end


    class TransactionManager
      include Singleton
      extend Forwardable
      
      def_delegators :@adapter, :transaction, :rescues

      def initialize
        set_adapter
      end

      private

      def set_adapter
        class_name = Madmass.config.tx_adapter.to_s.classify
        @adapter = "#{class_name}".constantize
      rescue NameError => nerr
        msg = "TransactionManager: error when setting the adapter: #{Madmass.config.tx_adapter}, class #{class_name} don't exists!"
        Madmass.logger.error msg
        raise "#{msg} -- #{nerr.message}"
      end

    end

  end
end

