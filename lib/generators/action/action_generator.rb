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

class ActionGenerator < Rails::Generators::NamedBase

  desc "This generator creates an action file at lib/actions and a test file at test/unit"

  source_root File.expand_path("../templates", __FILE__)

  #Adds in the lib/action directory a "file_name action" rb class template
  def generate_action
    template "action.rb.erb", "lib/actions/#{file_name}_action.rb"
  end

  #Adds in the test/unit directory  a "file_name action" unit test template
  def generate_test
    template "action_unit_test.rb.erb", "test/unit/#{file_name}_action_test.rb"
  end

end