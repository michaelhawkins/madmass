Rails.application.routes.draw do

  match 'commands', :to => 'commands#execute', :via => [:post]
  root :to => 'home#index'
  mount Madmass::Engine => "/madmass"
end
