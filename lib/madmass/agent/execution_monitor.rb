module Madmass
  module Agent
    module ExecutionMonitor

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

        # Execute external exception handling
        if rescue_proc = Madmass.rescues[error.class]
          rescue_proc.call
          return
        end
        
        #FIXME error_policy = action_policy[:error][error.class]
        #FIXME error_policy.call if error_policy

        # The exception is raised again, so that it can be properly dealt with in the upper
        # layers of the stack
        raise error
      end

      #      # FIXME policy returns the error or success actions in the form of an hash like this:
      #      #
      #      #   {:error => {error1 => action1, error2 => action2, ...}, :success => action}
      #      #
      #      def policy
      #        unless(@policy)
      #          if(Madmass.env == 'test')
      #            error_notify = Proc.new do
      #              Madmass.logger.info('TEST: sending error messages (simulation)')
      #            end
      #            success_notify = Proc.new do
      #              Madmass.logger.info('TEST: sending percept and success messages (simulation)')
      #            end
      #          else
      #            error_notify = Proc.new do
      #              @comm_strategy.send_messages(messages)
      #            end
      #            success_notify = Proc.new do
      #              @comm_strategy.send_percept(Madmass.current_percept)
      #              @comm_strategy.send_messages(messages)
      #            end
      #          end
      #
      #          @policy = {
      #            :error =>{
      #              Madmass::Errors::WrongInputError => error_notify,
      #              Madmass::Errors::NotApplicableError => error_notify
      #            },
      #            :success => success_notify
      #          }
      #        end
      #
      #        return @policy
      #      end
      #
    end
  end
end
