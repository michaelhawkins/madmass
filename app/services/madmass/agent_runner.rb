# AgentFarm
#module Madmass
  class AgentRunner < TorqueBox::Messaging::MessageProcessor
    def on_message(perception)
      ActiveSupport::Notifications.instrument("madmass.agent_queue_received")
      Madmass::AgentFarm::Domain::UpdaterFactory.updater.update_domain(perception)
    end
  end
#end
