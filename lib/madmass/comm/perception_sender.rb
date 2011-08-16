module Madmass
  module Comm

    class PerceptionSender
      include Singleton

      class << self
        def send(js, options = {})
          # FIXME: different send mechanism configurable
          # Socky.send(js.html_safe, options)
          puts "fake send: #{js}"
        end
      end
    end

  end
end

