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

require "#{File.dirname(__FILE__)}/../helper"

class ActionTest < Test::Unit::TestCase
  should "instantiate a simple action and execute it" do
    agent = Madmass::Agent::ProxyAgent.new
    status = agent.execute(:cmd => 'madmass::test::simple')
    assert_equal 'ok', status
  end

  
#  should "execute action with right status" do
#    agent = Madmass::Test::RealAgent.new
#    agent.status = :state1
#    assert_equal :state1, agent.status
#
#    agent.execute(:cmd => 'madmass::test::stateful')
#    assert_equal 'state3', Madmass.current_agent.status
#    assert_equal 'state3', agent.status
#
#    assert_raise Madmass::Errors::StateMismatchError do
#      agent.execute(:cmd => 'madmass::test::stateful')
#    end
#
#    # the action responds to 2 states
#    agent.status = :state2
#    assert_equal :state2, agent.status
#    agent.execute(:cmd => 'madmass::test::stateful')
#    assert_equal 'state3', Madmass.current_agent.status
#    assert_equal 'state3', agent.status
#
#  end
#
#  should "execute a complete action" do
#    agent = Madmass::Test::BuildAgent.new
#    assert_raise Madmass::Errors::StateMismatchError do
#      agent.execute(:cmd => 'madmass::test::build',  :initial_placement => 1, :target => 10)
#    end
#
#    agent.status = :play
#
#    result = agent.execute(:cmd => 'madmass::test::build',  :initial_placement => 1, :target => 10)
#
#    assert_equal result, :precondition_failed
#
#    agent.action_applicable = true
#    status = agent.execute(:cmd => 'madmass::test::build',  :initial_placement => 1, :target => 10)
#    assert_equal status, :ok
#    assert_equal 1, agent.executions
#
#    perception = Madmass.current_perception
#
#    assert perception
#    assert_equal perception.size, 1
#    assert_equal perception[0].data, {:message => "some data"}
#    assert_equal perception[0].header[:topics], 'all'
#    assert_equal perception[0].header[:clients], '1'
#    assert_equal perception[0].status,{:code => '100'}
#    assert_equal perception[0].header[:agent_id], "#{agent.id}"
#    assert_equal perception[0].header[:action], "Madmass::Test::BuildAction"
#  end

end


