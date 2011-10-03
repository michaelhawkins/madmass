require "#{File.dirname(__FILE__)}/helper"

class TestAction < Test::Unit::TestCase
  should "instantiate a simple action and execute it" do
    agent = Madmass::Agent::ProxyAgent.new
    agent.execute(:cmd => 'madmass::test::simple')
    #assert_equal({}, percept)
  end

  should "execute action with right status" do
    agent = Madmass::Test::RealAgent.new
    agent.status = :state1
    assert_equal :state1, agent.status

    agent.execute(:cmd => 'madmass::test::stateful', :agent => agent)
    assert_equal 'state3', Madmass.current_agent.status
    assert_equal 'state3', agent.status

    assert_raise Madmass::Errors::StateMismatchError do
      agent.execute(:cmd => 'madmass::test::stateful', :agent => agent)
    end

    # the action responds to 2 states
    agent.status = :state2
    assert_equal :state2, agent.status
    agent.execute(:cmd => 'madmass::test::stateful', :agent => agent)
    assert_equal 'state3', Madmass.current_agent.status
    assert_equal 'state3', agent.status

  end

  should "execute a complete action" do
    agent = Madmass::Test::BuildAgent.new
    assert_raise Madmass::Errors::StateMismatchError do
      agent.execute(:cmd => 'madmass::test::build', :agent => agent, :initial_placement => 1, :target => 10)
    end
    
    agent.status = :play
    assert_raise Madmass::Errors::NotApplicableError do
      agent.execute(:cmd => 'madmass::test::build', :agent => agent, :initial_placement => 1, :target => 10)
    end

    agent.action_applicable = true
    agent.execute(:cmd => 'madmass::test::build', :agent => agent, :initial_placement => 1, :target => 10)
    assert_equal 1, agent.executions
  end

end


