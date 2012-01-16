module Madmass
  module AuthenticationHelper
    private

    # Use Devise to authenticate the user and set the Madmass Current Agent for actions execution.
    def authenticate_agent
      authenticate_user!
#      unless current_user.agent
#        current_user.create_agent!(:status => 'init')
#        current_user.save!
#      end
#      Madmass.current_agent = current_user.agent
      Madmass.current_agent = Madmass::Agent::ProxyAgent.new(:status => 'init')
    end
  end
end
