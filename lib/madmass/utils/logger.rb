# This is the module that manages the logging facilities.
# You can attach the Madmass logger to the Rails logger if you use it or use the
# internal logger (TODO).

module Madmass
  module Utils

    # The internal logger.
    class Logger
      include Singleton
      
      def error msg
        puts msg
      end

      def info msg
        puts msg
      end

      def debug msg
        puts msg
      end
    end
    
    module Loggable
      # FIXME: invoke the right logger
      # FIXME: prefer torquebox logger if TorqueBox is defined
      def logger
        if defined?(Rails)
          Rails.logger
        else
          Logger.instance
        end
      end

    end
    
  end
end

