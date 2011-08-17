module Madmass
  module Atomic

    def transaction &block
      Madmass::Atomic::TransactionManager.instance.transaction do
        block.call
      end
    end

    class TransactionManager
      include Singleton

      def initialize
        set_adapter
      end

      def transaction &block
        @adapter.transaction do
          block.call
        end
      end

      private

      def set_adapter
        class_name = Madmass.config.tx_adapter.to_s.classify
        @adapter = "#{class_name}".constantize
      rescue NameError => nerr
        msg = "TransactionManager: error when setting the manager: #{Madmass.config.tx_adapter}, class #{class_name} don't exists!"
        Madmass.logger.error msg
        raise "#{msg} -- #{nerr.message}"
      end

    end

  end
end

