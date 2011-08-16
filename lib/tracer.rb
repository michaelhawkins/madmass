# Load the Tracer module

# require all tracer classes
Dir.glob(File.join(Madmass.root, 'madmass', 'tracer', '**', '*.rb')).each do |source|
  require source
end

# Every object can be traceable
class Object
  include Madmass::Tracer
end