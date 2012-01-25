
module Madmass
  module Transaction
    module TxMonitor
     
      def tx_monitor &block

        Madmass.transaction do
          block.call
         end

      rescue Exception => exc
        Madmass.logger.error("#{exc.class}: #{exc.message} \n #{exc.backtrace.join("\n")}")
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
