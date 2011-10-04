class AgentControllerGenerator < Rails::Generators::NamedBase

  desc "This generator creates ajax and html controllers, for linking the user to the agent"

  source_root File.expand_path("../templates", __FILE__)

  #Adds in the lib/action directory a "file_name action" rb class template
  #Adds in the test/unit directory  a "file_name action" unit test template
  def render_action_files
    raise "The agent controller name can not be blank!" if file_name.blank?
    template "agent_controller.rb.erb", "app/controllers/#{file_name}_agent_controller.rb"
    route(" match '#{file_name}_agent', :to => '#{file_name}_agent#execute'")
  end

end