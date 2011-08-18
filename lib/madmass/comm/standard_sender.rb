module Madmass
  module Comm

    class StandardSender
      include Singleton

      class << self
        def send(js, options = {})
          # FIXME: different send mechanism configurable
          # Socky.send(js.html_safe, options)
          js
        end
      end
    end

  end
end

