#http://guides.rubyonrails.org/generators.html#application-templates
#http://edgeguides.rubyonrails.org/rails_application_templates.html

#Dependency with MADMASS
gem("madmass", :git => "git://github.com/algorithmica/madmass.git", :branch => "master" )


#MADMASS initialization

initializer("madmass.rb", %Q{
  Madmass.setup do |config|
    # Configure Madmass in order to use the Active Record transaction adapter,
    # default is :"Madmass::Atomic::NoneAdapter".
    # You can also create your own adapter and pass it to the configuration
    # config.tx_adapter = :'Madmass::Atomic::ActiveRecordAdapter'

    # Configure Madmass to use
    config.perception_sender = :'Madmass::Comm::SockySender'
  end
  })

#Autoload files in lib
inject_into_file 'config/application.rb', 
  "\n\t config.autoload_paths += %W(\#{config.root}/lib)",
  :after => "# Custom directories with classes and modules you want to be autoloadable."
inject_into_file 'config/application.rb', 
  "\n\t config.autoload_paths += Dir[\"\#{config.root}/lib/**/\"]",
  :after => "# Custom directories with classes and modules you want to be autoloadable."





#DB related stuff

return if no?("Would you like to use a DB? (yes/no)")


#Installation of Devise for authentication (optional)
if yes?("Would you like to install Devise for authentication?(yes/no)")
  gem("devise")
  generate("devise:install")
  model_name = ask("What would you like the user model to be called? [user]")
  model_name = "user" if model_name.blank?
  generate("devise", model_name)
end

if yes?("Would you like to migrate the DBs?")

  rake "db:create", :env => 'development'
  rake "db:migrate", :env => 'development'

  rake "db:create", :env => 'test'
  rake "db:migrate", :env => 'test'

  rake "db:create", :env => 'production'
  rake "db:migrate", :env => 'production'
end
