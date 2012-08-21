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

      # Executes a given action as specified in the usr_opts
      def execute(usr_opts = {})
        Madmass.logger.debug "\n\n\n***********************************************************************"
        Madmass.logger.debug "***********************************************************************"
        Madmass.logger.debug "*  EXECUTING COMMAND #{usr_opts.inspect}"
        Madmass.logger.debug "***********************************************************************"
        Madmass.logger.debug "***********************************************************************\n"
        #prepare opts
        opts = usr_opts.clone
        opts[:agent] = self

        #Reset perception, that will later be populated by the action
        Madmass.current_perception = []

        #execute the command (transactional)
        status = do_it opts

        #dispatch generated percepts
        Madmass.dispatch_percepts

        #return the request status
        #the actual perception is stored in
        #in Madmass.current_perception
        Madmass.logger.debug "\n#########################################################################"
        Madmass.logger.debug "#########################################################################\n\n\n"
        return status
      end


      private

      # This is the method that fires the action execution. Any action instance previously created through the Action::ActionFactory, can be executed by calling this method.
      # This method essentially checks the action preconditions by calling #applicable? method, then if the action is applicable call the #execute method,
      # otherwise it raise Madmass::Errors::NotApplicableError exception.
      #
      # Returns: an http status Rails constant
      #
      # Raises: Madmass::Errors::NotApplicableError

      def do_it opts

        #create the action
        action = Madmass::Action::ActionFactory.make(opts)
        Madmass.logger.debug "Created action with\n #{opts.to_yaml}\n"

        tx_monitor do

          # check action specific applicability
          unless action.applicable?
            Madmass.logger.debug "action not applicable: #{action.inspect}"
            raise Madmass::Errors::NotApplicableError
          end

          # execute action
          action.execute
          Madmass.logger.debug "Action Executed"

          # generate percept (in Madmass.current_perception)
          action.build_result
          Madmass.logger.debug "Percept generated \n #{Madmass.current_perception.to_yaml}\n"
        end

        return :ok #http status

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


      def error_percept_factory(action, error, opts)

        error_msg = "#{action} #{error.class}: #{error.message}"
        Madmass.logger.error error_msg
        error_msg += " - #{action.why_not_applicable.messages}" if action and action.why_not_applicable.any?
        Madmass.logger.error("Error during processing: #{$!}, #{error_msg}")
        Madmass.logger.debug("Backtrace:\n\t#{error.backtrace.join("\n\t")}")


        e = Madmass::Perception::Percept.new(action)
        e.status = {:code => opts[:code], :exception => error.class.name}
        e.data.merge!({:message => opts[:message]}) if opts[:message]
        e.data.merge!({:why_not_applicable => opts[:why_not_applicable]}) if opts[:why_not_applicable]

        Madmass.current_perception << e
      end


    end
  end
end