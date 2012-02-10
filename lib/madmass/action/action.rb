
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
#   class Action::MyAction < Madmass::Action::Action
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
  module Action
    class Action
      include Madmass::Action::Stateful

      class_attribute :valid_params

      # Use it in your subclasses to define a list of parameters comma separated (symbols or strings)
      def self.action_params(*params)
        self.valid_params ||= Set.new
        self.valid_params += params.map(&:to_s).to_set
      end

      # Define a list of communication private channels (symbols or strings)
      attr_accessor :clients, :channels

      # Validates parameters declared using #action_params and calls process_params method (that you can override to add parameters preprocessing
      # or any computation to be performed before execution)
      def initialize parameters = {}
        validate parameters # raises Madmass::Errors::WrongInputError
        @parameters = parameters
        @why_not_applicable = nil
        @clients = Set.new
        @channels = Set.new
        process_params
      end

     
      def why_not_applicable
        @why_not_applicable ||= ActiveModel::Errors.new(self)
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

      def remote?
        false
      end
      
      private
      
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