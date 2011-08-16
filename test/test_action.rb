require "#{File.dirname(__FILE__)}/helper"

class TestAction < Test::Unit::TestCase
  should "instantiate a simple action and execute it" do
    action = Madmass::Mechanics::ActionFactory.make(:cmd => 'simple')
    assert action
    assert_equal({}, action.do_it)
  end
end


