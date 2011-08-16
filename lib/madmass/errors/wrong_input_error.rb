# This type of error is raised when a method receives some imput from the client
# that is wrong either semantically or sintactically. This may happen if there is
# someone trying to hack the system or there is a bug in the client.
module Madmass
  module Errors
    class WrongInputError < Madmass::Errors::MadmassError
    end
  end
end