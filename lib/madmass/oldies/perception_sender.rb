require 'forwardable'

module Madmass
  module Comm

    class PerceptionSender
      include Singleton
      extend Forwardable

      def_delegators :@sender, :send

      def initialize
        set_sender
      end

#      def send(js, options = {})
#        @sender.send(js, options)
#      end
      
      private

      def set_sender
        class_name = Madmass.config.perception_sender.to_s.classify
        @sender = "#{class_name}".constantize
      rescue NameError => nerr
        msg = "PerceptionSender: error when setting the sender: #{Madmass.config.perception_sender}, class #{class_name} don't exists!"
        Madmass.logger.error msg
        raise "#{msg} -- #{nerr.message}"
      end
    end

  end
end

