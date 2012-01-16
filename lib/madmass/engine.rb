module Madmass
  class Engine < Rails::Engine
    isolate_namespace Madmass
    
    # tell to the main app to precompile madmass assets
#    initializer :assets do |config|
#      images = Dir.glob(File.join(Madmass.root, 'app', 'assets', 'stylesheets', 'madmass', 'ui-darkness', 'images', '*.png'))
#      Rails.application.config.assets.precompile += images
#    end
  end
end
