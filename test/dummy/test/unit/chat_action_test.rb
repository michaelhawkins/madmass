require File.join('test', 'test_helper')
require File.dirname(__FILE__)+'/../../lib/actions/chat_action.rb'


class ChatActionTest < ActiveSupport::TestCase


  test "a Chat" do

    agent = Madmass::Agent::ProxyAgent.new

    assert_not_nil agent

    status = agent.execute(:cmd => 'actions::chat', :message => 'Hello World!')

    perception = Madmass.current_perception

    assert perception

    #more testing code here

    assert_equal 1, perception.size
    percept = perception.first
    assert_equal 'Hello World!', percept.data[:message]
    assert_equal 'all', percept.header[:topics]
    assert_equal 'ok', percept.status[:code]
    assert_equal agent.id.to_s, percept.header[:agent_id]
    assert_equal 'Actions::ChatAction', percept.header[:action]
  end

end
