require "#{File.dirname(__FILE__)}/helper"

class TestTransactionManager < Test::Unit::TestCase
  should "use active record adapter" do
    ##FIXME    puts Madmass.config.tx_adapter
    #    Madmass.config.load(File.join(Madmass.root, 'madmass', 'test', 'config', 'madmass_config.yml'))
    #    Madmass.transaction do
    #      # do nothing
    #    end
  end
end


