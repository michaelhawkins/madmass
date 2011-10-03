module Madmass
  module Observation

    # This is the Singleton class that holds the current perception instance.
    class CurrentAccessor
      include Singleton
      attr_accessor :perception
    end

    # This module is used to provide a global access to the current perception, of the
    # action in execution, in all classes by invoking Madmass.current_perception.
    module Current
      def current_perception
        Observation::CurrentAccessor.instance.perception
      end

      def current_perception=(perception)
        Observation::CurrentAccessor.instance.perception = perception
      end
    end
  end

end