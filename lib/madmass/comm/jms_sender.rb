module Madmass
  module Comm
          
    class JmsSender
      include Singleton
      
      class << self
        def send(percepts, opts)
          topic.publish(JSON(percepts), :properties => opts)
          # notify that a perception is sent
          ActiveSupport::Notifications.instrument("madmass.perception_sent")
        end

        def topic
          # FIXME: move destination name in Madmass.config
          @topic ||= TorqueBox::Messaging::Topic.new('/topic/perceptions')
        end
      end
      
    end

  end
end

