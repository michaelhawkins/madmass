# TODO: check if singleton is needed!
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
  end

  module Action
    autoload :Action, 'madmass/action/action'
    autoload :ActionFactory, 'madmass/action/action_factory'
    autoload :Stateful, 'madmass/action/stateful'
    autoload :ClassMethods, 'madmass/action/stateful'
    autoload :InstanceMethods, 'madmass/action/stateful'
  end

  module Comm
    autoload :Dispatcher, 'madmass/comm/dispatcher'
    autoload :DispatcherAccessor, 'madmass/comm/dispatcher'
    autoload :DummySender, 'madmass/comm/dummy_sender'
    autoload :PerceptGrouper, 'madmass/comm/percept_grouper'
    autoload :SockySender, 'madmass/comm/socky_sender'
  end

  module Errors
    class MadmassError < StandardError
    end

    autoload :CatastrophicError, 'madmass/errors/catastrophic_error'
    autoload :NotApplicableError, 'madmass/errors/not_applicable_error'
    autoload :StateMismatchError, 'madmass/errors/state_mismatch_error'
    autoload :WrongInputError, 'madmass/errors/wrong_input_error'
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

end

module Madmass
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