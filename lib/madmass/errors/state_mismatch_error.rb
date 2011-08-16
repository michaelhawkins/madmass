# This exception is raised when an agent tries to perform an action
# in a state that does not support that action.
module Madmass
  module Errors
    class StateMismatchError < Madmass::Errors::MadmassError
    end
  end
end

