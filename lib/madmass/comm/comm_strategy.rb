module Madmass
  module Comm

    class CommStrategy
      include Madmass::Comm::Helper

      def initialize action
        @context = action
      end

      def send_percept percept
        raise "Can not invoke #{self.class}::send_percept. This is an abstract method"
      end

      # Messages is an array of Comm::Message
      def send_messages messages
        groups = Madmass::Comm::MessageGrouper.new(messages)

        groups.messages_to_agents.each do |ch, msgs|
          js = [fire_event('info_mechanics', msgs)]
          send_to_player [ch], js
        end

        groups.messages_to_all.each do |ch, msgs|
          js = [fire_event('info_mechanics', msgs)]
          send_to_all [ch], js
        end
      end

    end

  end
end
