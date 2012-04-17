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

# This file provides access to the information inserted by the user
# during  the generation of the MADMASS template
module Madmass
  module Utils
    class InstallConfig
      include Singleton

      class << self

        # Returns the options for the given type.
        def options type
          @options[type]
        end

        # Loads the install configuration maintained in config/install_settings.yml
        def init
          @options = {}
          @options_path = File.join(Rails.root, 'config', 'install_settings.yml')
          @nodes_path = File.join("/tmp", "cluster_nodes.yml")
          load_options
        end

        private
        # Called by init to load the configuration file.
        def load_options
          raise "Cannot find install config file at #{@options_path}" unless File.file?(@options_path)
          @options = File.open(@options_path) { |yf| YAML::load(yf) }

          #Load cluster nodes IPs
           if File.file?(@nodes_path)
             @nodes = File.open(@nodes_path) { |yf| YAML::load(yf) }
             @options[:cluster_nodes] = @nodes
           else
             Madmass.logger.warn "Cannot find cluster nodes file at #{@nodes_path}, reverting to localhost"
             @options[:cluster_nodes] ={
               :geograph_nodes =>["localhost"],
               :agent_farm_nodes =>["localhost"],
               :agent_farm_modcluster_nodes=>["localhost"],
               :geograph_modcluster_nodes =>["localhost"],
               :db_nodes =>["localhost"]
             }
             end
        end
      end
    end
  end
end
