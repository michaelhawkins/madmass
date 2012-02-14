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

# AgentFarm
class PerceptionsProcessor < TorqueBox::Messaging::MessageProcessor

  def on_message(body)
    begin
      perceptions = JSON(body)
      agents_queue = TorqueBox::Messaging::Queue.new('/queue/agents')
      perceptions.each do |perception|
        agents_queue.publish(perception, :tx => false)
        ActiveSupport::Notifications.instrument("geograph-generator.agent_queue_sent")
      end
    rescue Exception => ex
      Madmass.logger.debug ex
    end
  end

end
