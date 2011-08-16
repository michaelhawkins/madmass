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

      def method_missing(method, *args)
        method = method.to_s
        if defined?(Rails)
          Rails.send(method)
        else
          env = method.sub(/\?$/, '')
          super unless ['test', 'development', 'production'].include?(env)
          return ENV['MADMASS_ENV'] == env
        end
      end
    end
    
  end
end
