require 'torquebox-stomp'
require 'torquebox-messaging'

module Madmass


  class CommandsStomplet < TorqueBox::Stomp::JmsStomplet

    include TorqueBox::Messaging
    include Madmass::ApplicationHelper


    def initialize()
      super
    end

    def configure(config)
      super
      @perceptions = Topic.new( config['perceptions_destination'] )
      @commands = Queue.new( config['commands_destination'] )
    end

    def on_message(message, session)
      send_to( @commands, message )
    end

    def on_subscribe(subscriber)
      subscribe_to( subscriber, @perceptions, "client='#{subscriber.session[:session_id]}' OR topic='all'" )
    end
   

    #      def on_unsubscribe(subscriber)
    #        @subscribers.delete(subscriber)
    #      end
  end
    
end