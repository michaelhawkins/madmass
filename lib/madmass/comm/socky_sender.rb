# TODO move into gvision
module Madmass
  module Comm
          
    class SockySender
      include Singleton

      class << self
        def send(js, options = {})
          Socky.send(js.html_safe, options)
        end
      end
    end

  end
end

