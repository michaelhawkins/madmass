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

# This is the module that manages the logging facilities.
# You can attach the Madmass logger to the Rails logger if you use it or use the
# internal logger (TODO).

module Madmass
  module Utils

    # The internal logger.
     #This is for be used in gem test environment were Rails logger is not available
    class Logger
      include Singleton

      #FIXME do not use puts, but rather the Ruby logger
      def error msg
        puts msg
      end

      def info msg
        puts msg
      end

      def debug msg
        puts msg
      end
    end

    module Loggable
      def logger
        if defined?(Rails)
          Rails.logger ||=  Logger.new(STDOUT)
        else
          Logger.instance
        end
      end

    end

  end
end

