# To change this template, choose Tools | Templates
# and open the template in the editor.

module Madmass
  module Perception
    class Percept
      attr_accessor  :header, :data

      def initialize
        @header ||= HashWithIndifferentAccess.new
        @data ||= HashWithIndifferentAccess.new
      end

    end
  end
end
