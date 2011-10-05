module Madmass
  module Comm
    
    class DummyCommStrategy < CommStrategy
      def dispatch percept
        #does nothing
      end
    end

  end
end