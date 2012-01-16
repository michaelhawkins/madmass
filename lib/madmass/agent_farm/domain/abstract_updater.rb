module Madmass
module AgentFarm
  module Domain

    class AbstractUpdater
      def update_domain(perception)
        #Madmass.logger.debug "Update #{perception.inspect}"
        #raise "AbstractUpdater::update_domain: you must override this method, this is an abstract class!"
      end
    end

  end
end
end
