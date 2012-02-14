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

# To change this template, choose Tools | Templates
# and open the template in the editor.

module Madmass
  module Comm
    class PerceptGrouper
      # FIXME: it doesn't make a good grouping job, should be better integrated with the builder to
    # minimize computation required for the maximum set reduction.
  
      def initialize(percepts)
        @topics = {}
        @clients = {}
        # Splits all topics
        percepts.each do |perc|
          topics = perc.header[:topics]
          clients = perc.header[:clients]
          topics.each {|t| @topics[t] ? @topics[t] << perc : @topics[t] = [perc]} unless topics.blank?
          clients.each {|c| @clients[c] ? @clients[c] << perc : @clients[c] = [perc]} unless clients.blank?
        end
      end

      def for_clients
        @clients
      end

      def for_topics
        @topics
      end

    end
  end
end
