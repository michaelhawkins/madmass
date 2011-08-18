# Load the Agent module

# require all agent classes
Dir.glob(File.join(Madmass.root, 'madmass', 'agent', '**', '*.rb')).each do |source|
  require source
end
