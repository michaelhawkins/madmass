# This module contains the logic required to keep track of changes to the state of objects manipulated by actions.
# This is very useful when the client side of the application that use Madmass needs to read perceptions (response
# messages) in the right order (the receiving order can be different because of network's lags).
# This wants to be a simple interface for managing versions of objects.
# In order to be traced the class must invoke in the class context the method *trace*:
#   class SomeObject
#     trace
#   end
module Madmass
  module Tracer

    # Trace object changes.
    # Requires an array of instance attributes (*options*) that needs to be monitorated in order to activate
    # the trace mechanism.
    # The trace mechanism uses a special attribute called *version* and increments its value at
    # every change that occur in attributes inside *options* (the method argument).
    # FIXME: must permit to define tracer for new types (other than ActiveRecord, OgmModel and Object)
    # by classes defined out of the madmass gem.
    def trace *options
      ancstrs = ancestors.map(&:to_s)
      if ancstrs.include?('ActiveRecord::Base')
        ar_trace options
      elsif ancstrs.include?('OgmModel')
        ogm_trace options
      else
        standard_trace options
      end
    end

    private

    # Simple ruby object trace implementation.
    # Define the version attribute and accessors for all attributes specified in the
    # *options* array. The setter for attributes in *options* increment the *version* value.
    def standard_trace options
      attr_reader :version
      
      options.each do |attr|
        attr_reader attr
        
        define_method "#{attr}=" do |value|
          instance_variable_set("@#{attr}", value)
          ver = instance_variable_get(:@version)
          ver ||= 0
          instance_variable_set(:@version, ver + 1)
        end
      end
    end

    # Active Record trace implementation.
    def ar_trace options
      set_locking_column :version
    end

    # Hibernate OGM trace implementation.
    def ogm_trace options

    end
  end
end
