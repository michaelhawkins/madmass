module Madmass
  module Perception

    # This is the Singleton class that holds the current perception instance.
    class CurrentAccessor
      include Singleton
      attr_accessor :perception
    end

    # This module is used to provide a global access to the current perception, of the
    # action in execution, in all classes by invoking Madmass.current_perception.
    module Current
      def current_perception
        Perception::CurrentAccessor.instance.perception #HACK TODO in a better way
      end

      def current_perception=(perception)
        Perception::CurrentAccessor.instance.perception = perception
      end
    end

  end
end