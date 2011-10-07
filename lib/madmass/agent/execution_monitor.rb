module Madmass
  module Agent
    module ExecutionMonitor
      #include Rescues;

      def exec_monitor &block

        #FIXME action_policy = policy

        Madmass.transaction do
          block.call
        end

        # must be outside transaction if involves communication (e.g., socky)
        #FIXME action_policy[:success].call

      rescue Exception => error
        # Errors are logged
        Madmass.logger.error("#{error.class}: #{error.message}")

        #TODO Build Error percept
        #in current percept
        #return

        #Send back to
        # Execute external exception handling
        #p = Percept.new
        #p.add_header(:)
        #
#        if rescue_proc = Madmass.rescues[error.class]
#          rescue_proc.call
#          return
#        end
        
        #FIXME error_policy = action_policy[:error][error.class]
        #FIXME error_policy.call if error_policy

        # The exception is raised again, so that it can be properly dealt with in the upper
        # layers of the stack
        raise error
      end

    end
  end
end
