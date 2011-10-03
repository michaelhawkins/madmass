# To change this template, choose Tools | Templates
# and open the template in the editor.

module Madmass
  module Perception
    class Percept
      attr_accessor  :header, :data, :status

      def initialize(context)
        @header = HashWithIndifferentAccess.new({
            :agent_id => "#{Madmass.current_agent.id}",
            :action => "#{context.class.name}"})
        @data = HashWithIndifferentAccess.new
        @status = HashWithIndifferentAccess.new
      end

    end
  end
end
