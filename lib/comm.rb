# Load the communication strategies module.
comm_path = File.join(Madmass.root, 'madmass', 'comm')
#require File.join(comm_path, 'helper')
require File.join(comm_path, 'percept_grouper')
require File.join(comm_path, 'dispatcher')


# require all comm strategy classes
Dir.glob(File.join(comm_path, '**', '*_sender.rb')).each do |source|
  require source
end