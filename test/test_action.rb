require "#{File.dirname(__FILE__)}/helper"

class TestAction < Test::Unit::TestCase
  should "instantiate a simple action and execute it" do
    action = Madmass::Mechanics::ActionFactory.make(:cmd => 'madmass::test::simple')
    assert action
    assert_equal({}, action.do_it)
  end

  should "execute action with right status" do
    agent = Madmass::Test::RealAgent.new
    agent.status = :state1
    assert_equal :state1, agent.status

    action = Madmass::Mechanics::ActionFactory.make(:cmd => 'madmass::test::stateful', :agent => agent)
    action.do_it
    assert_equal 'state3', Madmass.current_agent.status
    assert_equal 'state3', agent.status

    assert_raise Madmass::Errors::StateMismatchError do
      action.do_it
    end

    # the action responds to 2 states
    agent.status = :state2
    assert_equal :state2, agent.status
    action.do_it
    assert_equal 'state3', Madmass.current_agent.status
    assert_equal 'state3', agent.status

  end

  should "execute a complete action" do
    agent = Madmass::Test::BuildAgent.new
    action = Madmass::Mechanics::ActionFactory.make(:cmd => 'madmass::test::build', :agent => agent, :initial_placement => 1, :target => 10)
    assert_raise Madmass::Errors::StateMismatchError do
      action.do_it
    end
    
    agent.status = :play
    action = Madmass::Mechanics::ActionFactory.make(:cmd => 'madmass::test::build', :agent => agent, :initial_placement => 1, :target => 10)
    assert_raise Madmass::Errors::NotApplicableError do
      action.do_it
    end

    agent.action_applicable = true
    action = Madmass::Mechanics::ActionFactory.make(:cmd => 'madmass::test::build', :agent => agent, :initial_placement => 1, :target => 10)
    action.do_it
    assert_equal 1, agent.executions
  end

end


