#$:.unshift(File.dirname(__FILE__))
require 'monitorable'
require 'stateful'

# This is the base class for any action and defines a specific action definition pattern. This pattern can be briefly described below:
#
# 1. Define a new action class (e.g. my_new_action) that inherits from this base class.
# 2. OPTIONAL: declare action_params set. You can declare the parameter set of my_new_action, using the #action_params filter method (see example below).
#    If a client uses my_new_action and tries to create an instance of this class sending a param not declared in #action_params,
#    a GameErrors::WrongInputError will be raised, hence, if my_new_action definition doesn't declare #action_params,
#    no params will be accepted in the action costruction (i.e. this action is a paramless action).
# 3. OPTIONAL: Override #process_params. All the #action_params  will be placed in the @parameters variable and  can be preprocessed
#    in the optional #process_params method (called before #applicable? and #execute methods).
# 4. MANDATORY: Override #applicable?. In #applicable? you have to verify the action preconditions. Any kind of checks can be performed here,
#    but in general this method has to verify that the current action respects the action rules in order to be executed.
#    #applicable? is a boolean method so it has to return true if the action can be executed
#    (i.e. if #execute method will be executed), false otherwise. When an action is not applicable, a GameErrors::NotApplicableError exception will be raised
#    by the system. In the #applicable? method, if a certain condition is not verified you can use #why_not_applicable to describe
#    the reason adding an error-entry in the form of key => message. This feature allows any client to know
#    why a certain action is not applicable through  #why_not_applicable method that returns an ActiveModel::Errors.
# 5. MANDATORY: Override the #execute method. All the action side effects on the current state of the world have to be performed here.
#    The execution of #applicable? and #execute will be executed by the system in a single transaction .
# 6. MANDATORY: Override #build_result method. Any executed action returns a percept. The percept content can be defined in the #build_result method accessing Madmass.current_percept.
#
# So the workflow is:
#
# <tt>declare accepted parameters => process parameters => check applicability => execution => return a percept</tt>
#
# Example:
#
#   class Mechanics::MyAction < Madmass::Mechanics::Action
#     action_params :name, :last_name
#
#     private
#
#     def process_params
#       @parameters[:name] = @parameters[:name].strip
#     end
#
#     def applicable?
#       case
#         when @parameters[:name].blank?
#           why_not_applicable.add(:name, "You must provide the name")
#         when @parameters[:last_name].blank?
#           why_not_applicable.add(:last_name, "You must provide the last name")
#       end
#
#       return why_not_applicable.empty?
#     end
#
#     def execute
#       puts "Your full name is : #{@parameters[:name]} #{@parameters[:last_name]}"
#     end
#
#     def build_result
#        Madmass.current_percept[:players] = Player.all
#     end
#
#   end
#

module Madmass
  module Mechanics
    class Action
      include Madmass::Mechanics::Monitorable
      include Madmass::Mechanics::Stateful

      class_attribute :valid_params

      # Use it in your subclasses to define a list of parameters comma separated (symbols or strings)
      def self.action_params(*params)
        self.valid_params ||= Set.new
        self.valid_params += params.map(&:to_s).to_set
      end

      # Validates parameters declared using #action_params and calls process_params method (that you can override to add parameters preprocessing
      # or any computation to be performed before execution)
      def initialize parameters = {}
        validate parameters # raises Madmass::Errors::WrongInputError
        @parameters = parameters
        @why_not_applicable = nil

        Madmass.current_percept = {}

        @comm_strategy = Comm::StandardCommStrategy.new(self)
        @message_builder = Comm::MessageBuilder.new(self)
        process_params
      end

      def messages
        return @message_builder.messages
      end

      def why_not_applicable
        @why_not_applicable ||= ActiveModel::Errors.new(self)
      end

      # This is the method that fire the action execution. Any action instance previously created through the Mechanics::ActionFactory, can be executed by calling this method.
      # This method essentially checks the action preconditions by calling #applicable? method, then if the action is applicable call the #execute method,
      # otherwise it raise Madmass::Errors::NotApplicableError exception.
      #
      # Returns: a percept. You have to define the percept content (arranged in a hash) in the  #build_result method.
      #
      # Raises: Madmass::Errors::NotApplicableError
      def do_it
        exec_monitor do
          # we are in a transaction!

          # check if the action is applicable in the current state
          unless state_match?
            raise Madmass::Errors::StateMismatchError, I18n.t(:'action.state_mistmatch',
              {:agent_state => Madmass.current_agent.status,
                :action_states => applicable_states.join(", ")})
          end

          # check action specific applicability
          raise Madmass::Errors::NotApplicableError, why_not_applicable unless applicable?

          # execute action
          execute

          # change user state
          change_state

          # generate percept (must be extracted within the transaction)
          build_result
        end

        return Madmass.current_percept
      end

      private

      # policy returns the error or success actions in the form of an hash like this:
      #
      #   {:error => {error1 => action1, error2 => action2, ...}, :success => action}
      #
      def policy
        unless(@policy)
          if(Madmass.env == 'test')
            error_notify = Proc.new do
              Madmass.logger.info('TEST: sending error messages (simulation)')
            end
            success_notify = Proc.new do
              Madmass.logger.info('TEST: sending percept and success messages (simulation)')
            end
          else
            error_notify = Proc.new do
              @comm_strategy.send_messages(messages)
            end
            success_notify = Proc.new do
              @comm_strategy.send_percept(Madmass.current_percept)
              @comm_strategy.send_messages(messages)
            end
          end

          @policy = {
            :error =>{
              Madmass::Errors::WrongInputError => error_notify,
              Madmass::Errors::NotApplicableError => error_notify
            },
            :success => success_notify
          }
        end

        return @policy
      end

      # Override this method in your action to define the action postconditions.
      def execute
        raise "Action is abstract!"
      end

      # Override this method in your action to define the perception content.
      def build_result
      end

      # Override this method in your action to define when the action is applicable (i.e. to verify the action preconditions).
      def applicable?
        true
      end

      #      # Allows easy access to the configuration variables in the game_options.yml
      #      def options key
      #        GameOptions.options(Game.current.format)[key]
      #      end

      # Check if the parameters are a subset of accepted parameters for the action.
      def validate params
        params_set = params.keys.to_set
        valid_params = self.class.valid_params || Set.new
        raise(
          Madmass::Errors::WrongInputError,
          "#{self.class.name}: unexpected params: #{(params_set - valid_params).to_a.join(',')}"
        ) unless params_set.subset?(valid_params)
      end


      # Override this method to add parameters preprocessing code (if needed)
      def process_params
      end

    end
    
  end
end