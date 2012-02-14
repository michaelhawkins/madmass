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

# This class represents a single Percept generated as result of, possibly part of,
# an action. The current perception is an array of such percepts. Each percept
# is composed of three Hashes: the header, the data and the status.

module Madmass
  module Perception
    class Percept
      attr_reader  :header, :data, :status
      attr_writer :data, :status

      def add_headers headers
        @header.merge! headers
      end

      def initialize(context = nil)
        base_header = {:agent_id => "#{Madmass.current_agent.id}"}
        if context
          base_header.merge!({:action => context.class.name.split("::").map(&:underscore).join("::")})
          # set who must receive the perceptions for the action
          base_header.merge!({:topics => context.channels.map(&:to_s), :clients => context.clients.map(&:to_s)})
        end
        @header = HashWithIndifferentAccess.new(base_header)
        @data = HashWithIndifferentAccess.new
        @status = HashWithIndifferentAccess.new(:code => 'ok')
      end

      #Deep copy of the percept
      def clone
        tp = Percept.new
        tp.add_headers(@header.clone)
        tp.status = @status.clone
        tp.data = @data.clone
        return tp
      end

      
      #Returns a translated clone of the Percept.
      #Only the data hash is affected
      def translate
        return self if data.any?
        tp = self.clone
        recursive_translate(tp.data)
        return tp
      end

      # Does a deep (recursive) translation of the content hash passed as argument.
      # Any value in the  hash that corresponds to a key in the translation
      # file is translated.
      # *Note* The method does side-effect on the content
      def recursive_translate content
          
        content.each do |key,value|
          if value.is_a?(Hash)
            recursive_translate value
          else
            translation = I18n.t(value) if(value.is_a? Symbol)
            content[key] = translation if translation
          end
        end
      end
      
    end
  end
end
