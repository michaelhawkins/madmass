module Madmass
  module Generators

    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)
      desc "Installs gem files in the newly creted rails application"

      def copy_config_js
        copy_file "config.js", "app/assets/javascripts/config.js"
      end

      def copy_assets
        directory "../../../../assets", "lib/assets"
        directory "../../../../../vendor/assets", "vendor/assets"
      end

    end

  end
end
