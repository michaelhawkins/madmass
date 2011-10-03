# To change this template, choose Tools | Templates
# and open the template in the editor.

module Madmass
  module Observation
    class Perception

      attr_accessor :percepts

      def initialize
        @percepts = Array.new
      end

      
      def dispatch
        Madmass.current_perception.percepts.each do |percept|
          continue unless percept.header
          #send percepts to topics
          topics = percept.header.topics
          #TODO @comm_strategy.send_to_topics(t, percept) if topics.any?
          #send percepts to clients
          clients = percept.header.clients
          #TODO @comm_strategy.send_to_clients(clients, percept) if clients.any?
        end
      end
      
    end
  end
end
