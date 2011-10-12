# This file provides access to the information inserted by the user
# during  the generation of the MADMASS template
module Madmass
  class InstallConfig
    include Singleton

    class << self

      # Returns the options for the given type.
      def options type
        #HashWithIndifferentAccess.new @options[type]
        @options[type]
      end

      # Loads the game configuration maintained in config/game_options.yml
      def init
        @options = {}
        @options_path = File.join(Rails.root, 'config', 'install_settings.yml')
        load_options
      end

      private
      # Called by init to load the configuration file.
      def load_options
        raise "Cannot find game options file at #{@options_path}" unless File.file?(@options_path)
        #@options = File.open(@options_path) { |yf|  HashWithIndifferentAccess.new(YAML::load(yf)) }
        @options = File.open(@options_path) { |yf|  YAML::load(yf) }
      end

    end
  end
end