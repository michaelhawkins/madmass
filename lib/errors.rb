# This is the base class for any error produced by madmass.
module Madmass
  module Errors
    class MadmassError < StandardError

    end
  end
end

# require all errors classes
Dir.glob(File.join(Madmass.root, 'madmass', 'errors', '*.rb')).each do |source|
  require source
end