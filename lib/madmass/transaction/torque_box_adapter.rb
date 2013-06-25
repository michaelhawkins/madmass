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

# This is the transaction manager adapter for Active Record.
module Madmass
  module Transaction

    class TorqueBoxAdapter
      class << self
        def transaction &block
          Madmass.logger.debug "-- Madmass::Transaction::TorqueBoxAdapter::transaction --"
          TorqueBox.transaction do
            block.call
          end
        end

        def rescues #FIXME see CloudTM Adapter
          {ActiveRecord::Rollback => Proc.new {
              sleep(rand/4.0)
              #retry
              return
            },
           ActiveRecord::StaleObjectError => Proc.new {
              sleep(rand/4.0)
#              Game.current.reload if Game.current
#              Player.current.reload if Player.current
              #retry
              return
            }
          }
        end

      end
    end

  end
end
