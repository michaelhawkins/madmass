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

          def start(options = {:force => false})
            init_status if options[:force]
            
            if(running? and completed?)
              action = choose_action
              Madmass.logger.debug "Executing action: #{action.inspect}"
              persist_last_action action
              execute(action)
            end

          rescue Exception => ex
            on_error(ex)
          end

          def stop
            tx_monitor do
              self.last_action['status'] = 'stopped'
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
              self.last_action['status'] = 'paused'
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
            self.last_action = action.merge('status' => 'running')
            save
          end

          def completed?
            return true if self.last_action.blank?
            return false unless self.last_action['perception_status']
            return (with_success? or with_failure?)
          end

          def with_success?
            self.last_action['perception_status'] == 'ok'
          end

          def with_failure?
            self.last_action['perception_status'] == 'precondition_failed'
          end

          def running?
            return true if self.last_action.blank?
            return ((self.last_action['status'] != 'stopped') and (self.last_action['status'] != 'paused'))
          end
        end

      end
    end
  end
end
