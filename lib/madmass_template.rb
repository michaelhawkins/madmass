#http://guides.rubyonrails.org/generators.html#application-templates
#http://edgeguides.rubyonrails.org/rails_application_templates.html

#Dependency with MADMASS
gem("madmass", :git => "git://github.com/algorithmica/madmass.git", :branch => "js_integration")

#WebSockets
websockets = "socky"
user_ws = ask("Which implementation of websockets to you want to use?  (socky/none) [#{websockets}]" )
websockets = user_ws unless user_ws.blank?

case websockets
when 'none'
  ws_adapter = 'Madmass::Comm::DummySender'
when 'socky'
  ws_adapter = 'Madmass::Comm::SockySender'
  gem("socky-client", :version => "0.4.3")
  gem("socky-client-rails", :version => "0.4.5")
  gem("socky-server", :version => "0.4.1")
  host = "localhost"
  port= "9090"
  secret= "my_secret_key"
  secure = "false"
  user_host = ask("on what host will the socky server run? [#{host}]")
  host = user_host unless user_host.blank?

  user_port = ask("and on what port will it run? [#{port}]")
  port = user_port unless user_port.blank?

  passwd = ask("what password do you want to use? (leave blank to leave connection unsecured)")
  unless passwd.blank?
    secure = "true"
    secret = passwd
  end

  create_file "config/socky_hosts.yml" do
    %Q{
:hosts:
  - :host: #{host}
    :port: #{port}
    :secret: #{secret}
    :secure: #{secure}
    }

  end

  create_file "socky_server.yml" do
    %Q{
:port: 9090
:debug: false

# :subscribe_url: http://localhost:3000/socky/subscribe
# :unsubscribe_url: http://localhost:3000/socky/unsubscribe

:secret: my_secret_key

:secure: false

# :timeout: 3

# :log_path: /var/log/socky.log
# :pid_path: /var/run/socky.pid

# :tls_options:
#   :private_key_file: /private/key
#   :cert_chain_file: /ssl/certificate
    }
   
  end
end

#MADMASS initialization
initializer("madmass.rb", %Q{
  Madmass.setup do |config|
    # Configure Madmass in order to use the Active Record transaction adapter,
    # default is :"Madmass::Atomic::NoneAdapter".
    # You can also create your own adapter and pass it to the configuration
    # config.tx_adapter = :'Madmass::Atomic::ActiveRecordAdapter'

    # Configure Madmass to use
    config.perception_sender = "#{ws_adapter}"
  end
  })

#Autoload files in lib
inject_into_file 'config/application.rb',
  "\n\t config.autoload_paths += %W(\#{config.root}/lib)",
  :after => "# Custom directories with classes and modules you want to be autoloadable."
inject_into_file 'config/application.rb',
  "\n\t config.autoload_paths += Dir[\"\#{config.root}/lib/**/\"]",
  :after => "# Custom directories with classes and modules you want to be autoloadable."

#Requires for madmass js libraries
inject_into_file 'app/assets/javascripts/application.js',
  "\n//= require madmass\n//= require config",
  :after => "//= require jquery_ujs"

generate "madmass:install"

#DB related stuff

#return if no?("Would you like to use a DB? (yes/no)")
#
#
##Installation of Devise for authentication (optional)
#if yes?("Would you like to install Devise for authentication?(yes/no)")
#  gem("devise")
#  generate("devise:install")
#  model_name = ask("What would you like the user model to be called? [user]")
#  model_name = "user" if model_name.blank?
#  generate("devise", model_name)
#end
#
#if yes?("Would you like to migrate the DBs?")
#
#  rake "db:create", :env => 'development'
#  rake "db:migrate", :env => 'development'
#
#  rake "db:create", :env => 'test'
#  rake "db:migrate", :env => 'test'
#
#  rake "db:create", :env => 'production'
#  rake "db:migrate", :env => 'production'
#end
