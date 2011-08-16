$:.unshift(File.dirname(__FILE__))
require 'action'

# This class implements an action factory: given a set of params returns an
# appropriate instance of an action.
module Madmass
  module Mechanics


    class ActionFactory

      # All possible actions.
      #  VALID_COMMANDS = [
      #    :build_city,
      #    :build_colony,
      #    :build_road,
      #    :create_game,
      #    :join_game,
      #    :leave_game,
      #    :list_games,
      #    :production,
      #    :ecocrime,
      #    :trade_bank,
      #    :dump_game,
      #    :ready,
      #    :place_trade_request,
      #    :close_trade_request,
      #    :counter_offer,
      #    :accept_offer,
      #    :play,
      #    :chat,
      #    :playing_chat,
      #    :buy_progress,
      #    :use_social_progress,
      #    :place_road,
      #    :end_game
      #  ].freeze unless defined? VALID_COMMANDS

      # Returns the action instance.
      # Action instantiation can raise if there are errors in the given parameters.
      def self.make params
        begin
          options = process_params params
          cmd = options.delete(:cmd).to_s
          klass_name = "#{cmd.camelize}Action"
          klass = klass_name.constantize
          raise "#{klass_name} is not a subclass of Madmass::Mechanics::Action" unless klass.ancestors.include?(Madmass::Mechanics::Action)
          return klass.new(options)
        rescue NameError => ex
          msg = "ActionFactory: action #{klass_name} doesn't exists!"
          Madmass.logger.error msg
          raise ex
        end
      end

      private

      # Here we process parameters globally (for all actions).
      # Processing done:
      # * parameters are cloned in a HashWithIndifferentAccess.
      # * converts *target* from string array to fixnum array
      # * converts *initial_placement* from string to boolean
      def self.process_params params
        options = HashWithIndifferentAccess.new(params)
        raise(Madmass::Errors::WrongInputError, "#{self.name}: you did not specify any command!") if options[:cmd].blank?
        #raise(Madmass::Errors::WrongInputError, "#{self.name}: unexpected command #{options[:cmd]}") unless VALID_COMMANDS.include?(options[:cmd].to_sym)

        # Some global conversion. Action factory should not know about these params, but it's the
        # most convenient place to put them.
        if options[:target]
          raise Madmass::Errors::WrongInputError, "#{self.name}: target must be an array of coordinates!" unless options[:target].class == Array
          options[:target].map!(&:to_i) # NOTE to_i makes it Fixnum, so all decimal values are ignored
        end

        truefalseify(options, [:initial_placement, :ready])

        return options
      end

      def self.truefalseify(options, booleans)
        booleans.each do |bool|
          options[bool] = (options[bool].to_s == 'true' ? true : false) if options[bool]
        end
      end

    end
  end
end