# This module manages application environments like Rails envs.
# Uses the ENV environment variable.
# TODO: integrate with rails envs.

module Madmass
  module Utils
    
    module Env
      def env
        if defined?(Rails)
          Rails.env
        else
          ENV['MADMASS_ENV'] ||= 'development'
        end

      end

    end
    
  end
end
