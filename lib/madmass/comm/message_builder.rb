module Madmass
  # Message object used in the server => client communication
  module Comm

    class Message
      #
      # - contest [String]: is the mechanics action like build_city, trade_bank etc.
      #   It is useful for message grouping and filtergin operations.
      # - type [String]: message type, like 'info', 'warning', 'error'
      # - level [Integer]: a number >= 0 that represent the message level (like priority).
      #   The client can decide to show only higher message level of a given contest group.
      # - key [Symbol or String]: assigned in the initialization. It's the message id.
      # - message [String]: the actual message. The massage can have substitutions in the form of {subParam1} ...
      # - subs [Hash]: substitution parameters for the message. The client will do the substitutions.
      # - options [Hash]: a hash of optional options to pass to the client.
      # - users [Array]: array of socky client ids (for private messages)
      # - channels [Array]: array od socky channel ids (for public messages)
      attr_reader :contest, :type, :level, :key, :message, :subs, :options, :users, :channels

      def initialize(msg_params)
        translate(msg_params)

        # Assignments useful for inspection
        @contest = msg_params[:contest]
        @type = msg_params[:type]
        @level = msg_params[:level]
        @key = msg_params[:key]
        @message = msg_params[:message]
        @subs = msg_params[:subs]
        @options = msg_params[:options]
        @users = msg_params[:users]
        @channels = msg_params[:channels]

        # The real full message
        @full_message = msg_params.except(:key, :users, :channels)
      end

      def data
        @full_message
      end

      private

      # Translates the message if it's a symbol
      def translate(msg_params)
        msg_params[:key] = msg_params[:message]
        msg_params[:message] = I18n.t(msg_params[:message]) if(msg_params[:message].is_a? Symbol)
      end
    end

    # FIXME: it doesn't make a good grouping job, should be better integrated with the builder to
    # minimize computation required for the maximum set reduction.
    class MessageGrouper

      def initialize(messages)
        @channels = {}
        @users = {}
        # Splits all channels
        messages.each do |msg|
          data = msg.data
          msg.channels.each {|ch| @channels[ch] ? @channels[ch] << data : @channels[ch] = [data]}
          msg.users.each {|ch| @users[ch] ? @users[ch] << data : @users[ch] = [data]}
        end
      end

      def messages_to_agents
        @users
      end

      def messages_to_all
        @channels
      end

    end

    class MessageBuilder
      attr_reader :messages
    
      # Predefined message types. The builder generates dynamically a add method
      # for each type. Example: add_info, add_tip, ...
      TYPES = {
        :info => 'info',
        :tip => 'tip',
        :event => 'event',
        :result => 'result',
        :server => 'server'
      }.freeze unless defined? TYPES

      DEFAULTS = {
        :type => TYPES[:info],
        :level => 0,
        :subs => {},
        :options => nil,
        :users => [],
        :channels => []
      }.freeze unless defined? DEFAULTS

      REQUIRED = [:message].freeze unless defined? REQUIRED

      # Message added when the builder fails to add a message
      BUILD_ERROR_MSG = {
        :contest => 'message_builder',
        :type => TYPES[:server],
        :level => 1000,
      }.freeze unless defined? BUILD_ERROR_MSG

      def initialize(contest)
        @contest = contestualize contest
        @messages = []
        # Message is sent by default only to the current user
      
        # FIXME: resolve user id problem
        #@user = User.current ? User.current.id : nil # if called by the production action User.current is not defined
        @user = nil

        # Creates dynamic methods, one add_* for each TYPE
        create_adders
      end

      def add(msg)
        unless validate(msg)
          Madmass.logger.error("Wrong message parameters: #{msg.inspect}")
          error_msg = BUILD_ERROR_MSG.clone
          error_msg[:message] = "Wrong message parameters: {params}"
          error_msg[:subs] = {:params => msg.inspect}
          error_msg[:users] = [@user]
          msg = error_msg
        end
        msg[:contest] = @contest
        msg[:users] ||= [@user] if(@user and msg[:channels].blank?)
        @messages << Message.new(full_message(msg).clone)
      end

      private

      def create_adders
        TYPES.keys.each do |type|
          self.class.send(:define_method, "add_#{type}") {|msg| add_typed(msg, type)}
        end
      end

      def add_typed(msg, type)
        msg ||= {}
        msg[:type] = TYPES[type]
        add msg
      end

      # Returns a string representing the contest given the contest parameter that can be a String or any other class
      def contestualize(contest)
        return (contest.is_a?(String) ? contest : contest.class.name.demodulize.underscore)
      end

      # Fills the message with all parameters
      def full_message(params)
        return DEFAULTS.merge(params)
      end

      def validate(params)
        # Chck to see if we passed all required parameters
        valid = params and (REQUIRED - params.keys).empty?
        return valid
      end

    end
  end
end