# This is the module that manages the logging facilities.
# You can attach the Madmass logger to the Rails logger if you use it or use the
# internal logger (TODO).

module Madmass
  module Utils

    # The internal logger.
     #This is for be used in gem test environment were Rails logger is not available
    class Logger
      include Singleton

      #FIXME do not use puts, but rather the Ruby logger
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

