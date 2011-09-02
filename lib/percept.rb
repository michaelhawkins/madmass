# Load the Percept module

# require all percept classes
Dir.glob(File.join(Madmass.root, 'madmass', 'percept', '**', '*.rb')).each do |source|
  require source
end
