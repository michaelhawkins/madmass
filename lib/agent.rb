# Load the Agent module

# Load the agent modules.
agent_path = File.join(Madmass.root, 'madmass', 'agent')
require File.join(agent_path, 'executor')
require File.join(agent_path, 'f_s_a_executor')
require File.join(agent_path, 'current')
require File.join(agent_path, 'proxy_agent')
require File.join(agent_path, 'jms_executor') if defined? TorqueBox
