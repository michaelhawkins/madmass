# To change this template, choose Tools | Templates
# and open the template in the editor.

module Madmass
  module Agent
    module Rescues



            # FIXME policy returns the error or success actions in the form of an hash like this:
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
