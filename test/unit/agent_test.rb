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

require "helper"

class AgentTest < Test::Unit::TestCase
  should "use the global access for the current agent" do
    agent = Madmass::Test::RealAgent.new
    #FIXME is somehow already set sometimes -> assert_nil Madmass.current_agent
    Madmass.current_agent = agent
    assert_equal agent.id, Madmass.current_agent.id
  end

#  should "have initial status set to :initial" do
#    agent = Madmass::Test::RealAgent.new
#    assert_nil agent.status
#    agent.status = :new_state
#    assert_equal :new_state, agent.status
#  end

#  should "raise for agents without required attributes" do
#    assert_raise Madmass::Errors::WrongInputError do
#      agent = Madmass::Test::WrongAgent.new
#    end
# 
#  end
end


