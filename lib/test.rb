require 'active_record'

# require all test classes
Dir.glob(File.join(Madmass.root, 'madmass', 'test', '**', '*.rb')).each do |source|
  require source
end