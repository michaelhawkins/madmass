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

require 'singleton'
require "madmass/engine"

MADMASS_ROOT = File.dirname(__FILE__) unless defined?(MADMASS_ROOT)

module Madmass
  class << self
    def root
      MADMASS_ROOT
    end

    def gem_root
      File.join(Madmass.root, '..')
    end

    def config_root
      File.join(Madmass.root, '..', 'config')
    end

    def install_options opts
      Utils::InstallConfig.options opts
    end
  end

end

#Autoload of Classes
module Madmass

  module Agent
    autoload :CurrentAccessor, 'madmass/agent/current'
    autoload :Current, 'madmass/agent/current'
    autoload :Executor, 'madmass/agent/executor'
    autoload :FSAExecutor, 'madmass/agent/f_s_a_executor'
    autoload :JmsExecutor, 'madmass/agent/jms_executor'
    autoload :ProxyAgent, 'madmass/agent/proxy_agent'
    autoload :Association, 'madmass/agent/association'
  end

  module Action
    autoload :Action, 'madmass/action/action'
    autoload :RemoteAction, 'madmass/action/remote_action'
    autoload :ActionFactory, 'madmass/action/action_factory'
    autoload :Stateful, 'madmass/action/stateful'
    autoload :ClassMethods, 'madmass/action/stateful'
    autoload :InstanceMethods, 'madmass/action/stateful'
    autoload :WhyNotApplicable, 'madmass/action/why_not_applicable'
  end

  module Comm
    autoload :Dispatcher, 'madmass/comm/dispatcher'
    autoload :DispatcherAccessor, 'madmass/comm/dispatcher'
    autoload :DummySender, 'madmass/comm/dummy_sender'
    autoload :PerceptGrouper, 'madmass/comm/percept_grouper'
    autoload :SockySender, 'madmass/comm/socky_sender'
    autoload :JmsSender, 'madmass/comm/jms_sender'
  end

  module Errors
    class MadmassError < StandardError
    end

    autoload :CatastrophicError, 'madmass/errors/catastrophic_error'
    autoload :NotApplicableError, 'madmass/errors/not_applicable_error'
    autoload :StateMismatchError, 'madmass/errors/state_mismatch_error'
    autoload :WrongInputError, 'madmass/errors/wrong_input_error'
    autoload :RollbackError, 'madmass/errors/rollback_error'
  end

  module Perception
    autoload :Current, 'madmass/perception/current'
    autoload :CurrentAccessor, 'madmass/perception/current'
    autoload :Percept, 'madmass/perception/percept'
  end

  module Tracer
    autoload :Tracer, 'madmass/tracer/tracer'
  end

  autoload :Transaction, 'madmass/transaction/transaction_manager'

  module Transaction
    autoload :ActiveRecordAdapter, 'madmass/transaction/active_record_adapter'
    autoload :TorqueBoxAdapter, 'madmass/transaction/torque_box_adapter'
    autoload :NoneAdapter, 'madmass/transaction/none_adapter'
    autoload :TransactionManager, 'madmass/transaction/transaction_manager'
    autoload :TxMonitor, 'madmass/transaction/tx_monitor'
  end

  module Utils
    autoload :Config, 'madmass/utils/config'
    autoload :Configurable, 'madmass/utils/config'
    autoload :Env, 'madmass/utils/env'
    autoload :InstallConfig, 'madmass/utils/install_config'
    autoload :Logger, 'madmass/utils/logger'
    autoload :Loggable, 'madmass/utils/logger'
  end

  module AgentFarm
    module Agent
      autoload :AutonomousAgent, 'madmass/agent_farm/agent/autonomous_agent'
      autoload :JmsMessenger, 'madmass/agent_farm/agent/jms_messenger'
      autoload :Controllable, 'madmass/agent_farm/agent/controllable'
      autoload :ExecutionStats, 'madmass/agent_farm/agent/execution_stats'
      autoload :Behavior, 'madmass/agent_farm/agent/behavior'
    end

    module Domain
      autoload :UpdaterFactory, 'madmass/agent_farm/domain/updater_factory'
      autoload :AbstractUpdater, 'madmass/agent_farm/domain/abstract_updater'
    end


  end

  class << self
    include Madmass::Utils::Loggable
    include Madmass::Utils::Env
    include Madmass::Utils::Configurable
    include Madmass::Transaction
    include Madmass::Agent::Current
    include Madmass::Perception::Current
    include Madmass::Comm::Dispatcher
  end

end

# Every object can be traceable
class Object
  include Madmass::Tracer::Tracer
end
