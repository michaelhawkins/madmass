module Madmass
  module Comm
          
    class SockySender
      include Singleton
      
      class << self
        def send(pecepts,opts)
          Socky.send(percepts.to_json.html_safe,opts) #FIXME
        end
      end
      
    end

  end
end

