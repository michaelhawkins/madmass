module Madmass
  module Mechanics
    module Monitorable

      def exec_monitor &block

        action_policy = policy

        Madmass.transaction do
          block.call
        end

        # must be outside transaction if involves communication (e.g., socky)
        action_policy[:success].call

      rescue Exception => error
        # Errors are logged
        Madmass.logger.error("#{error.class}: #{error.message}")

        # Execute external exception handling
        if rescue_proc = Madmass.rescues[error.class]
          rescue_proc.call
          return
        end
        
        error_policy = action_policy[:error][error.class]
        error_policy.call if error_policy

        # The exception is raised again, so that it can be properly dealt with in the upper
        # layers of the stack
        raise error
      end
      
    end
  end
end
