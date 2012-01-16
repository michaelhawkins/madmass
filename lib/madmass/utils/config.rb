module Madmass
  module Utils

    class Config
      include Singleton

      attr_accessor :tx_adapter, :perception_sender, :domain_updater
      
      def initialize
        @tx_adapter = :"Madmass::Transaction::NoneAdapter"
        @perception_sender = :"Madmass::Comm::DummySender"
        @domain_updater = :"AgentFarm::Domain::AbstractUpdater"
      end

      # Overrides default values for all configurations in the yaml file passed
      # as argument.
      def load(file_path)
        return unless File.exists?(file_path)
        conf = YAML.load(File.read(file_path))
        # override tx_manager
        @tx_adapter = conf['tx_adapter'] if conf['tx_adapter']
        @perception_sender = conf['perception_sender'] if conf['perception_sender']
        @domain_updater = conf['domain_updater'] if conf['domain_updater']
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
