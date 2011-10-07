module Madmass
  module Generators

    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)
      desc "Installs gem files in the newly creted rails application"

      argument :keys, :type => :string
      argument :values, :type => :string

      def initialize(names, args, options)
        super
        # FIXME Really can not do it differently??
        @options = Hash[*keys.split(',').zip(values.split(',')).flatten]
      end

      def install_js_core
        copy_file "config.js", "app/assets/javascripts/madmass/config.js"
        directory "../../../../assets", "lib/assets"
        directory "../../../../../vendor/assets", "vendor/assets"
      end

      def setup_socky
        if(@options['ws_adapter'] == 'Madmass::Comm::SockySender')
          template "socky_server.yml.erb", "socky_server.yml"
          template "socky_hosts.yml.erb", "config/socky_hosts.yml"
          remove_file "app/helpers/application_helper.rb"
          copy_file "application_helper.rb", "app/helpers/application_helper.rb"
        end
      end

    end

  end
end
