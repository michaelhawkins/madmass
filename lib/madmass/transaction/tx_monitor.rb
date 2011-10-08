#TODO this file should be moved into the transaction directory 
module Madmass
  module Transaction
    module TxMonitor
     
      def tx_monitor &block

        Madmass.transaction do
          block.call
        end

      rescue Exception => exc
        policy = Madmass.rescues[exc.class]
        if Madmass.rescues[exc.class]
          policy.call
        else
          raise exc;
        end
      end

      
    end
  end
end
