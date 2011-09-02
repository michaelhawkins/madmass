require "#{File.dirname(__FILE__)}/helper"

class TestAgent < Test::Unit::TestCase
  should "use the global access for the current agent" do
    agent = Madmass::Test::RealAgent.new
    assert_nil Madmass.current_agent
    Madmass.current_agent = agent
    assert_equal agent.id, Madmass.current_agent.id
  end

  should "have initial status set to :initial" do
    agent = Madmass::Test::RealAgent.new
    assert_nil agent.status
    agent.status = :new_state
    assert_equal :new_state, agent.status
  end

  should "raise for agents without required attributes" do
    assert_raise Madmass::Errors::WrongInputError do
      agent = Madmass::Test::WrongAgent.new
    end
    
  end
end


