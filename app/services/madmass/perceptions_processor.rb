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
