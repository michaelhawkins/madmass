# To change this template, choose Tools | Templates
# and open the template in the editor.

module Madmass
  module Comm
    class PerceptGrouper
      # FIXME: it doesn't make a good grouping job, should be better integrated with the builder to
    # minimize computation required for the maximum set reduction.
  
      def initialize(percepts)
        @topics = {}
        @clients = {}
        # Splits all topics
        percepts.each do |perc|
          topics = perc.header[:topics]
          clients = perc.header[:clients]
          topics.each {|t| @topics[t] ? @topics[t] << perc : @topics[t] = [perc]} if topics.any?
          clients.each {|c| @clients[c] ? @clients[c] << perc : @clients[c] = [perc]} if clients.any?
        end
      end

      def for_clients
        @clients
      end

      def for_topics
        @topics
      end

    end
  end
end
