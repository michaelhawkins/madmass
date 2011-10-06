class AgentControllerGenerator < Rails::Generators::NamedBase

  desc "This generator creates ajax and html controllers, for linking the user to the agent"

  source_root File.expand_path("../templates", __FILE__)

  #Adds in the lib/action directory a "file_name action" rb class template
  #Adds in the test/unit directory  a "file_name action" unit test template
  def generate_controller
    template "agent_controller.rb.erb", "app/controllers/#{file_name}_agent_controller.rb"
    route("match '#{file_name}', :to => '#{file_name}_agent#execute', :via => [:post]")
  end

  def generate_view
    template "agent_view.rb.erb", "app/views/#{file_name}_agent/execute.html.erb"
  end

end