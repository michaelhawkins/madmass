# require all atomic classes
Dir.glob(File.join(Madmass.root, 'madmass', 'atomic', '*.rb')).each do |source|
  require source
end