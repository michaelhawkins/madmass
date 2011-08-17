module Madmass
  module Mechanics
    module Monitorable

      def exec_monitor &block

        action_policy = policy

        Madmass.transaction do
          block.call
        end

#        ActiveRecord::Base.transaction do #FIXME, should not be AR!
#          block.call
#        end

        # must be outside transaction if involves communication (e.g., socky)
        action_policy[:success].call

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
##        Game.current.reload if Game.current
##        Player.current.reload if Player.current
#
#        exec_monitor do
#          block.call
#        end
#        return
      rescue Exception => error
        # Errors are logged
        Madmass.logger.error("#{error.class}: #{error.message}")

        error_policy = action_policy[:error][error.class]
        error_policy.call if error_policy

        # The exception is raised again, so that it can be properly dealt with in the upper
        # layers of the stack
        raise error
      end
      
    end
  end
end
