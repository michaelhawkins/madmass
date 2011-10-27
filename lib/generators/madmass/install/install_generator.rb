module Madmass
  module Generators

    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)
      desc "Installs gem files in the newly created rails application"

      argument :keys, :type => :string
      argument :values, :type => :string

      def initialize(names, args, options)
        super
        # FIXME Really can not do it differently??
        @options = Hash[*keys.split(',').zip(values.split(',')).flatten]
      end
      
      def install_js_core
        copy_file "config.js", "app/assets/javascripts/madmass/config.js"
      end

      def install_styles
        directory "../../../../../vendor/assets/stylesheets/ui-darkness", "app/assets/stylesheets/ui-darkness"
        directory "../../../../assets/stylesheets", "app/assets/stylesheets"
        remove_file "app/assets/stylesheets/application.css"
        copy_file "application.css", "app/assets/stylesheets/application.css"
      end

      def setup_socky
        if(@options['ws_adapter'] == 'Madmass::Comm::SockySender')
          template "socky_server.yml.erb", "socky_server.yml"
          template "socky_hosts.yml.erb", "config/socky_hosts.yml"
          remove_file "app/helpers/application_helper.rb"
          copy_file "application_helper.rb", "app/helpers/application_helper.rb"
        end
      end

      def add_torquebox_confs
         copy_file "torquebox.yml", "config/torquebox.yml" if @options['torquebox']
      end

      def store_install_confs
        create_file 'config/install_settings.yml', %Q{# THIS IS AN AUTOMATICALLY GENERATED\n# DO NOT EDIT MANUALLY \n
        } + @options.to_yaml
      end
    end

  end
end
