require 'forwardable'

module Madmass
  module Atomic

    def transaction &block
      Madmass::Atomic::TransactionManager.instance.transaction do
        block.call
      end
    end

    def rescues
      Madmass::Atomic::TransactionManager.instance.rescues
    end


    class TransactionManager
      include Singleton
      extend Forwardable
      
      def_delegators :@adapter, :transaction, :rescues

      def initialize
        set_adapter
      end

      private

      def set_adapter
        class_name = Madmass.config.tx_adapter.to_s.classify
        @adapter = "#{class_name}".constantize
      rescue NameError => nerr
        msg = "TransactionManager: error when setting the adapter: #{Madmass.config.tx_adapter}, class #{class_name} don't exists!"
        Madmass.logger.error msg
        raise "#{msg} -- #{nerr.message}"
      end

    end

  end
end

