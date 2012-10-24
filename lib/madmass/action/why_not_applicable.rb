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
  module Action
    class WhyNotApplicable < ActiveModel::Errors
      attr_reader :recipients, :levels, :subs, :types
      attr_reader :levels

      def initialize(base)
        super(base)
        @recipients = HashWithIndifferentAccess.new
        @levels = HashWithIndifferentAccess.new
        @types = HashWithIndifferentAccess.new
        @subs = HashWithIndifferentAccess.new
      end

      # Adds the message (using the ActiveModel::Errors api) and stores
      # the message recipients for the message
      def publish(options = {})
        add(options[:name], options[:key])
        @recipients[options[:name]] = options[:recipients] || []
        @levels[options[:name]] = options[:level] || 0
        @types[options[:name]] = options[:type] || 'info'
        @subs[options[:name]] = options[:subs]
      end
    end
  end
end
