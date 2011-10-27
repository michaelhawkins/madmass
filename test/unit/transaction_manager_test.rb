require "helper"

class TransactionManagerTest < Test::Unit::TestCase
  should "use active record adapter" do
    Madmass.config.tx_adapter
    Madmass.config.load(File.join(Madmass.root, 'madmass', 'test', 'config', 'madmass_config.yml'))
    Madmass.transaction do
      # do nothing
    end
  end
end


