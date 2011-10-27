require "helper"

class ConfigTest < Test::Unit::TestCase
  should "override default configuration via yaml file" do
    assert_equal :'Madmass::Transaction::NoneAdapter', Madmass.config.tx_adapter
    Madmass.config.load(File.join(Madmass.root, 'madmass', 'test', 'config', 'madmass_config.yml'))
    assert_equal :'Madmass::Transaction::ActiveRecordAdapter', Madmass.config.tx_adapter
    assert_equal :'Madmass::Comm::SockySender', Madmass.config.perception_sender
  end
end


