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

$:.unshift(File.dirname(__FILE__))
require 'action'

# This class implements an action factory: given a set of params returns an
# appropriate instance of an action.
module Madmass
  module Action

    class ActionFactory
      # Returns the action instance.
      # Action instantiation can raise if there are errors in the given parameters.
      def self.make params
        begin
          klass_name = nil
          options = nil
          Madmass.logger.debug "making action with params #{params.to_yaml}" if (Madmass.logger.level_enabled? :debug)
          #measure = Benchmark.measure do

            options = process_params params
            cmd = options.delete(:cmd).to_s.strip
            klass_name = "#{cmd.split('::').map(&:camelize).join('::')}Action"
            simple_name =klass_name.downcase
            is_normalized = (simple_name.start_with?("madmass::action::") or simple_name.start_with?("actions::")) #FIXME HACK for RemoteAction
            Madmass.logger.debug "Classname before normalization #{klass_name} \n Normalized #{is_normalized}" if (Madmass.logger.level_enabled? :debug)
            klass_name = "Actions::" + klass_name unless is_normalized
          #end
          #Madmass.logger.info("[make] parameters: \t"+measure.to_s)

          Madmass.logger.debug "Will constantize classname #{klass_name}" if (Madmass.logger.level_enabled? :debug)
          klass = nil
         # measure = Benchmark.measure do
            klass = klass_name.constantize
         # end
          #Madmass.logger.info("Constantize: \t"+measure.to_s)

          #measure = Benchmark.measure do
            raise "#{klass_name} is not a subclass of Madmass::Action::Action" unless klass.ancestors.include?(Madmass::Action::Action)
          #end
          #Madmass.logger.info("ancestors: \t"+measure.to_s)

          result = nil
          #measure = Benchmark.measure do
            result = klass.new(options)
          #end
          #Madmass.logger.info("new: \t"+measure.to_s)

          return result
        end

      rescue NameError => ex
        msg = "ActionFactory: action #{klass_name} doesn't exists!"
        Madmass.logger.error msg
        raise ex
      rescue LoadError => ex
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
        # set the global current agent
        Madmass.current_agent = options.delete(:agent)
        return options
      end


    end
  end
end