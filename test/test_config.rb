require "#{File.dirname(__FILE__)}/helper"

class TestConfig < Test::Unit::TestCase
  should "override default configuration via yaml file" do
    assert_equal :'Madmass::Atomic::NoneAdapter', Madmass.config.tx_adapter
    Madmass.config.load(File.join(Madmass.root, 'madmass', 'test', 'config', 'madmass_config.yml'))
    assert_equal :'Madmass::Atomic::ActiveRecordAdapter', Madmass.config.tx_adapter
    assert_equal :'Madmass::Comm::SockySender', Madmass.config.comm
  end
end


