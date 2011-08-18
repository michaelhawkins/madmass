module Madmass
  module Test

    # This class is used to simulate an agent without the required attributes (i.e. id).
    class WrongAgent
      undef :id
      include Madmass::Agent
    end
    
  end
end
