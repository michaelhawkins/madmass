module Madmass
  module Comm
    
    class DummyCommStrategy < CommStrategy
      def send_percept percept
        #does nothing
      end
    end

  end
end