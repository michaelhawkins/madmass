# Load the Percept module

# require all percept classes
Dir.glob(File.join(Madmass.root, 'madmass', 'observation', '**', '*.rb')).each do |source|
  require source
end
