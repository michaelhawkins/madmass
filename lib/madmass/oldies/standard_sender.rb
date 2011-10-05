module Madmass
  module Comm

    class StandardSender
      include Singleton

      class << self
        def send(js, options = {})
          js
        end
      end
    end

  end
end

