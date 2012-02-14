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

class AgentControllerGenerator < Rails::Generators::Base

  desc "This generator creates ajax and html controllers, for linking the user to the agent"

  source_root File.expand_path("../templates", __FILE__)
  
  argument :file_name, :type => :string
  class_option :devise, :type => :boolean, :default => true, :desc => "Include Devise (requires AR)."

  #Adds in the lib/action directory a "file_name action" rb class template
  #Adds in the test/unit directory  a "file_name action" unit test template
  def generate_controller

    controller_path ="app/controllers/#{file_name}_controller.rb"

    template "agent_controller.rb.erb", controller_path

    route("match '#{file_name}', :to => '#{file_name}#execute', :via => [:post]")
  end

  def generate_view
    template "agent_view.rb.erb", "app/views/#{file_name}/execute.html.erb"
  end

end