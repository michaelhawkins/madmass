###############################################################################
###############################################################################
#
# This file is part of MADMASS (MAssively Distributed Multi Agent System Simulator).
#
# Copyright (c) 2012 Algorithmica Srl
#
# MADMASS is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# MADMASS is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with MADMASS.  If not, see <http://www.gnu.org/licenses/>.
#
# Contact us via email at info@algorithmica.it or at
#
# Algorithmica Srl
# Vicolo di Sant'Agata 16
# 00153 Rome, Italy
#
###############################################################################
###############################################################################


module Madmass
  module Agent
    module Executor
      include Madmass::Transaction::TxMonitor

      def execute(usr_opts = {})

        #prepare opts
        opts = usr_opts.clone
        opts[:agent] = self
        #opts[:cmd] = "Actions::"+ opts[:cmd]

        #Reset perception, that will be populated by the following actions
        Madmass.current_perception = []

        #execute the command (transactional)
        status = do_it opts

        #dispatch generated percepts
        Madmass.dispatch_percepts

        #return the I18n perception
        return status
      end


      # This is the method that fires the action execution. Any action instance previously created through the Action::ActionFactory, can be executed by calling this method.
      # This method essentially checks the action preconditions by calling #applicable? method, then if the action is applicable call the #execute method,
      # otherwise it raise Madmass::Errors::NotApplicableError exception.
      #
      # Returns: an http status Rails constant
      #
      # Raises: Madmass::Errors::NotApplicableError


      def do_it opts

        #create the action
        action = create_action(opts)

        # FIXME: NativeException: java.lang.Error: Nested transactions not supported yet...
        # current hack: if the action is remote we don't open a transaction (because the transaction is already opened by
        # code that invoke the action
        if action.remote?
          process(action)
        else
          tx_monitor do
            # we are in a transaction!
            process(action)
          end
        end

        return 'ok' #http status

      rescue Madmass::Errors::StateMismatchError => exc
        raise exc

      rescue Madmass::Errors::NotApplicableError => exc
        error_percept_factory(action, exc,
                              :code => 'precondition_failed',
                              :why_not_applicable => action.why_not_applicable.as_json)
        return :precondition_failed #http status

      rescue Madmass::Errors::WrongInputError => exc
        error_percept_factory(action, exc,
                              :code => 'bad_request',
                              :message => exc.message)
        return :bad_request #http status

      rescue Madmass::Errors::CatastrophicError => exc
        error_percept_factory(action, exc,
                              :code => 'internal_server_error',
                              :message => exc.message)
        return :internal_server_error #http status

      rescue Exception => exc
        error_percept_factory(action, exc,
                              :code => 'service_unavailable',
                              :message => exc.message)
        return :service_unavailable #http status
      end
    end
  end

  private

  def process(action)
    # check if the action is consistent with behavioral specification
    # e.g., FSA, PNP, etc ...
    behavioral_validation(action)

    # check action specific applicability
    unless action.applicable?
      raise Madmass::Errors::NotApplicableError
    end

    # execute action
    action.execute

    # change user state
    action.change_state

    # generate percept (in Madmass.current_percept)
    action.build_result
  end

  def create_action(opts)
    # when the remote option is passed other options are translated to create a remote action
    if opts.delete(:remote)
      data = opts.clone
      cmd = "madmass::action::remote"
      opts = {:cmd => cmd, :data => data}
    end
    Madmass::Action::ActionFactory.make(opts)
  end

  def error_percept_factory(action, error, opts)

    error_msg = "#{action} #{error.class}: #{error.message}"
    error_msg += " - #{action.why_not_applicable.messages}" if action and action.why_not_applicable.any?
    Madmass.logger.error(error_msg)

    e = Madmass::Perception::Percept.new(action)
    e.status = {:code => opts[:code], :exception => error.class.name}
    e.data.merge!({:message => opts[:message]}) if opts[:message]
    e.data.merge!({:why_not_applicable => opts[:why_not_applicable]}) if opts[:why_not_applicable]

    Madmass.current_perception << e
  end

  def behavioral_validation action
    return true;
  end

end
end
end