# active support deps
require File.join('active_support', 'hash_with_indifferent_access') unless defined?(HashWithIndifferentAccess)
require File.join('active_support', 'core_ext', 'class', 'attribute') #unless method_defined?(:class_attribute)
#require 'active_support/core_ext/string' #unless method_defined?(:blank?)
#require File.join('active_support', 'core_ext', 'string', 'inflections')
require 'singleton'

# require all utils classes
Dir.glob(File.join(Madmass.root, 'madmass', 'utils', '*.rb')).each do |source|
  require source
end