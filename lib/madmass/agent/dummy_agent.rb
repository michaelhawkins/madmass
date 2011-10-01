module Madmass
  module Agent
    class DummyAgent
      include Madmass::Agent
      def initialize
        @status = :none
      end
    end
  end
end
