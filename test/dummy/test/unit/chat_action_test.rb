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

require File.join('test', 'test_helper')
require File.dirname(__FILE__)+'/../../lib/actions/chat_action.rb'


class ChatActionTest < ActiveSupport::TestCase


  test "a Chat" do

    agent = Madmass::Agent::ProxyAgent.new

    assert_not_nil agent

    status = agent.execute(:cmd => 'actions::chat', :message => 'Hello World!')

    perception = Madmass.current_perception

    assert perception

    #more testing code here

    assert_equal 1, perception.size
    percept = perception.first
    assert_equal 'Hello World!', percept.data[:message]
    assert_equal 'all', percept.header[:topics]
    assert_equal 'ok', percept.status[:code]
    assert_equal agent.id.to_s, percept.header[:agent_id]
    assert_equal 'Actions::ChatAction', percept.header[:action]
  end

end
