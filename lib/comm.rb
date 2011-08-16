# Load the communication strategies module.
comm_path = File.join(Madmass.root, 'madmass', 'comm')
require File.join(comm_path, 'helper')
require File.join(comm_path, 'perception_sender')
require File.join(comm_path, 'message_builder')
require File.join(comm_path, 'comm_strategy')

# require all comm strategy classes
Dir.glob(File.join(comm_path, '**', '*_comm_strategy.rb')).each do |source|
  require source
end