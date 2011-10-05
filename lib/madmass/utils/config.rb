module Madmass
  module Utils

    class Config
      include Singleton

      attr_accessor :tx_adapter, :perception_sender
      
      def initialize
        @tx_adapter = :"Madmass::Atomic::NoneAdapter"
        @perception_sender = :"Madmass::Comm::DummySender"
      end

      # Overrides default values for all configurations in the yaml file passed
      # as argument.
      def load(file_path)
        return unless File.exists?(file_path)
        conf = YAML.load(File.read(file_path))
        # override tx_manager
        @tx_adapter = conf['tx_adapter'] if conf['tx_adapter']
        @perception_sender = conf['perception_sender'] if conf['perception_sender']
      end
      
    end

    module Configurable
      def config
        Madmass::Utils::Config.instance
      end

      def setup &block
        yield(config)
      end
    end

  end
end
