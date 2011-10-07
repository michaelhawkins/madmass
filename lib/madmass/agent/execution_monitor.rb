module Madmass
  module Agent
    module ExecutionMonitor
      #include Rescues;

      def exec_monitor &block

        Madmass.transaction do
          block.call
        end

        #      FIXME: remove dependency with AR!
        #      rescue ActiveRecord::Rollback => exc
        #        Rails.logger.info("#{exc.class}: #{exc.message}")
        #        sleep(rand(1)/4.0)
        #        exec_monitor do
        #          block.call
        #        end
        #        return
        #
        #      rescue ActiveRecord::StaleObjectError => exc
        #        Rails.logger.info("#{exc.class}: #{exc.message}")
        #        sleep(rand(1)/4.0)
        #
        #        exec_monitor do
        #          block.call
        #        end
        #        return
      end
    end
  end
end
