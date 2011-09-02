module Madmass
  module Percept

    # This is the Singleton class that holds the current perception instance.
    class CurrentAccessor
      include Singleton
      attr_accessor :percept
    end

    # This module is used to provide a global access to the current perception, of the
    # action in execution, in all classes by invoking Madmass.current_percept.
    module Current
      def current_percept
        Percept::CurrentAccessor.instance.percept
      end

      def current_percept=(percept)
        Percept::CurrentAccessor.instance.percept = percept
      end
    end
  end

end