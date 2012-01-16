module Madmass
module AgentFarm
  module Domain

    class UpdaterFactory
      def self.updater
        class_name = Madmass.config.domain_updater.to_s.classify
        "#{class_name}".constantize.new
      rescue NameError => nerr
        msg = "UpdaterFactory: error when setting the domain updater: #{Madmass.config.domain_updater}, class #{class_name} don't exists!"
        Madmass.logger.error msg
        raise "#{msg} -- #{nerr.message}"
      end
    end

  end
end
end
