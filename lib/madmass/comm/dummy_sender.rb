# To change this template, choose Tools | Templates
# and open the template in the editor.

module Madmass
  module Comm
    class DummySender
       include Singleton

      class << self
        def send(percepts,opts)
          #process(percepts)

        end
      end
    end
  end
end
