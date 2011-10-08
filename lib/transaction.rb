# require all transaction classes
Dir.glob(File.join(Madmass.root, 'madmass', 'transaction', '*.rb')).each do |source|
  require source
end