module Madmass
  module Utils

    class Config
      include Singleton

      attr_accessor :tx_adapter, :comm
      
      def initialize
        @tx_adapter = :"Madmass::Atomic::NoneAdapter"
        @comm = :"Madmass::Comm::StandardSender"
      end

      # Overrides default values for all configurations in the yaml file passed
      # as argument.
      def load(file_path)
        return unless File.exists?(file_path)
        conf = YAML.load(File.read(file_path))
        # override tx_manager
        @tx_adapter = conf['tx_adapter'] if conf['tx_adapter']
        @comm = conf['comm'] if conf['comm']
      end
    end

    module Configurable
      def config
        Madmass::Utils::Config.instance
      end
    end

  end
end
