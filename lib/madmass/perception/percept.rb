# This class represents a single Percept generated as result of, possibly part of,
# an action. The current perception is an array of such percepts. Each percept
# is composed of three Hashes: the header, the data and the status.

module Madmass
  module Perception
    class Percept
      attr_reader  :header, :data, :status
      attr_writer :data, :status

      def add_headers headers
        @header.merge! headers
      end


      def initialize(context)
        @header = HashWithIndifferentAccess.new({
            :agent_id => "#{Madmass.current_agent.id}",
            :action => context.class.name})
        @data = HashWithIndifferentAccess.new
        @status = HashWithIndifferentAccess.new
      end

    end
  end
end
