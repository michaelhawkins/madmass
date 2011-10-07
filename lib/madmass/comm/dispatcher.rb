# To change this template, choose Tools | Templates
# and open the template in the editor.

module Madmass
  module Comm

    # This module is in charge of dispatching perceptions (i.e., arrays of percepts)


    # This is the Singleton class that holds the Dispatcher instance.
    class DispatcherAccessor
      include Singleton

      def dispatch_percepts
        grouper = PerceptGrouper.new(Madmass.current_perception)

        grouper.for_clients.each do |client, percepts|
          @sender.send(percepts.map{|p| p.translate}, :client => client)
        end

        grouper.for_topics.each do |topic, percepts|
          @sender.send(percepts.map{|p| p.translate}, :topics => topic)
        end

      end

      def initialize
        class_name = Madmass.config.perception_sender.to_s.classify
        @sender = "#{class_name}".constantize
      rescue NameError => nerr
        msg = "Dispatcher: error when setting the sender: #{Madmass.config.perception_sender}, class #{class_name} don't exists!"
        Madmass.logger.error msg
        raise "#{msg} -- #{nerr.message}"
      end

      private



    end

    # This module is used to provide a global access to the percept dispatcher,
    # in all classes by invoking Madmass.send_percepts.
    module Dispatcher
      def dispatch_percepts
        Comm::DispatcherAccessor.instance.dispatch_percepts
      end
    end

  end
end
