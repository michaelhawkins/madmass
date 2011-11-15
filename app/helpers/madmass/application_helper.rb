module Madmass
  module ApplicationHelper
    private
    
    def authenticate_agent
      authenticate_user!
      unless current_user.agent
        current_user.create_agent!(:status => 'init')
        current_user.save!
      end
      Madmass.current_agent = current_user.agent
    end
  end
end
