#http://guides.rubyonrails.org/generators.html#application-templates
#http://edgeguides.rubyonrails.org/rails_application_templates.html

#Dependency with MADMASS
#gem("madmass", :git => "git://github.com/algorithmica/madmass.git", :branch => "master")
gem("madmass", :path =>"/Users/vittorio/dev/projects/madmass")

#WebSockets
websockets = "socky"
user_ws = ask("Which implementation of websockets to you want to use?  (socky/none) [#{websockets}]" )
websockets = user_ws unless user_ws.blank?

config = {}

case websockets
when 'none'
  config['ws_adapter'] = 'Madmass::Comm::DummySender'
when 'socky'
  config['ws_adapter'] = 'Madmass::Comm::SockySender'
  gem("socky-client", :version => "0.4.3")
  gem("socky-client-rails", :version => "0.4.5")
  gem("socky-server", :version => "0.4.1")
  config['host'] = "localhost"
  config['port'] = "9090"
  config['secure'] = "false"
  config['secret'] = "my_secret_key"
  user_host = ask("on what host will the socky server run? [#{config['host']}]")
  config['host'] = user_host unless user_host.blank?

  user_port = ask("and on what port will it run? [#{config['port']}]")
  config['port'] = user_port unless user_port.blank?

  passwd = ask("what password do you want to use? (leave blank to leave connection unsecured)")
  unless passwd.blank?
    config['secure'] = "true"
    config['secret'] = passwd
  end
end



#DB related stuff
#Installation of Devise for authentication (optional)
reply = ask("Would you like to install Devise for authentication?(yes/no)[yes]")
config[:db] = false
config[:ar] = false
config[:devise] = false

if(reply.strip.downcase == 'yes' or reply.blank?)
  config[:db] = true
  config[:ar] = true
  config[:devise] = true
  gem("devise")
  generate("devise:install")
  model_name = ask("What would you like the user model to be called? [user]").underscore

  model_name = "user" if model_name.blank? or model == "agent"

  config[:user_model] = model_name
  generate("devise", model_name)

  #Generate the agent model
  generate("model", "agent  status:string")
  inject_into_file "app/models/agent.rb",
  "\n include Madmass::Agent",
  :after => "class Agent < ActiveRecord::Base"

  #Generate relationship "User belongs to Agent"
  model_name  = model_name.camelize
  inject_into_file "app/models/#{model_name}.rb",
  "\n belongs_to :agent",
  :after => "class #{model_name} < ActiveRecord::Base"

  #Generate migrations
  generate("migration", "AddAgentIdTo#{model_name} agent_id:integer")
  
  #Create and migrate the db
  reply = ask("Would you like to create and migrate the DBs?(yes/no) [yes]")
  if(reply.strip.downcase == 'yes' or reply.blank?)
    rake "db:create", :env => 'development'
    rake "db:migrate", :env => 'development'

    rake "db:create", :env => 'test'
    rake "db:migrate", :env => 'test'

    rake "db:create", :env => 'production'
    rake "db:migrate", :env => 'production'
  end
end

#Autoload files in lib
inject_into_file 'config/application.rb',
  "\n\t config.autoload_paths += %W(\#{config.root}/lib)",
  :after => "# Custom directories with classes and modules you want to be autoloadable."

inject_into_file 'config/application.rb',
  "\n\t config.autoload_paths += Dir[\"\#{config.root}/lib/**/\"]",
  :after => "# Custom directories with classes and modules you want to be autoloadable."

inject_into_file 'config/application.rb',
  "\n\t config.assets.paths << \"\#{Madmass.gem_root}/vendor/assets/javascripts\"
   \t config.assets.paths << \"\#{Madmass.gem_root}/lib/assets/javascripts\"",
  :after => "config.assets.version = '1.0'"

#Requires for madmass js libraries
inject_into_file 'app/assets/javascripts/application.js',
  "\n//= require madmass\n//= require madmass/config",
  :after => "//= require jquery_ujs"

run 'bundle install'
generate "madmass:install", config.keys.join(','), config.values.join(',')

#MADMASS initialization
initializer("madmass.rb", %Q{
  Madmass.setup do |config|
    # Configure Madmass in order to use the Active Record transaction adapter,
    # default is :"Madmass::Transaction::NoneAdapter".
    # You can also create your own adapter and pass it to the configuration
   #{
      "config.tx_adapter = :'Madmass::Transaction::ActiveRecordAdapter'" if @ar
    }

    # Configure Madmass to use
    config.perception_sender = "#{config['ws_adapter']}"
    Madmass::InstallConfig.init
 end
  })

#TORQUEBOX
reply = ask("Would you like to make this app a Torquebox app?(yes/no)[no]")
if(reply.strip.downcase == 'yes')
  gem 'activerecord-jdbc-adapter'
  gem 'jdbc-sqlite3'
  rake "rails:template LOCATION=$TORQUEBOX_HOME/share/rails/template.rb"
end
