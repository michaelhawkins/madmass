module Madmass
  module Action

    class RemoteAction < Madmass::Action::Action
      #include TorqueBox::Injectors
      action_params :data
      #action_states :none
      #next_state :none
      
      def initialize params = {}
        super
        @queue = TorqueBox::Messaging::Queue.new(Madmass.install_options(:commands_queue))
        @queue.connect_options = {
          :naming_host => Madmass.install_options(:naming_host),
          :naming_port => Madmass.install_options(:naming_port)
        }
      end

      def execute
        # Disable transactions because this method is invoked by a backgroundable method.
        # With transactions enabled all publish will send the data at the end of job operations.
        @parameters[:data][:agent] = {:id => @parameters[:data][:agent].id}
        Madmass.logger.debug "RemoteAction data: #{@parameters[:data].inspect}"
        @queue.publish((@parameters[:data] || {}).to_json, :tx => false)
        # notify that a remote command is sent
        ActiveSupport::Notifications.instrument("madmass.command_sent")
      end

      def build_result
      end

      def remote?
        true
      end
      
    end
    
  end
end

