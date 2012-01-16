module Madmass
module AgentFarm
  module Agent
    module AutonomousAgent

      include Madmass::Agent::Executor
      include Madmass::Transaction::TxMonitor
      
      def self.included(base)
        base.send(:include, InstanceMethods)
      end

      module InstanceMethods
        
        def start(options = {:delay => 5, :force => false})
          sleep(options[:delay])
          reload
          init_status if options[:force]
          #if not stopped?
          if running?
            tx_monitor do
              if completed?
                action = choose_action
                Madmass.logger.debug "Executing action: #{action.inspect}"
                persist_last_action action
                execute(action)
              end
            end
          end

        rescue Exception => ex
          on_error(ex)
        end

        def stop
          tx_monitor do
            self.last_action['code'] = 'stopped'
            save
          end
        rescue Exception => ex
          @stop_retry ||= 1
          if @stop_retry >= 10
            Madmass.logger.error "Max retries for stop reached (10) - exception was: #{ex}"
            return
          end
          Madmass.logger.error "Retry #{@stop_retry} for stop reached (10) - exception was: #{ex}"
          @stop_retry += 1
          sleep(rand(1)/4.0)
          retry
        end

        def pause
          tx_monitor do
            self.last_action['code'] = 'paused'
            save
          end
        rescue Exception => ex
          @pause_retry ||= 1
          if @pause_retry >= 10
            Madmass.logger.error "Max retries for pause reached (10) - exception was: #{ex}"
            return
          end
          Madmass.logger.error "Retry #{@pause_retry} for pause reached (10) - exception was: #{ex}"
          @pause_retry += 1
          sleep(rand(1)/4.0)
          retry
        end

        private


        def init_status
          self.last_action = {}
          save
        end

        def persist_last_action action
          self.last_action = action.merge('code' => 'running')
          save
        end

        def completed?
          return true if self.last_action.blank?
          return false unless self.last_action['perception']
          self.last_action['perception']['status']['code'] == 'ok'
        end

#        def stopped?
#          return false unless self.last_action
#          self.last_action['code'] == 'stopped'
#        end

        def running?
          return true unless self.last_action
          (self.last_action['code'] != 'stopped') and (self.last_action['code'] != 'paused')
        end
      end

    end
  end
end
end
