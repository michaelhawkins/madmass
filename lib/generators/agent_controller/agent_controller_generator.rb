class AgentControllerGenerator < Rails::Generators::Base

  desc "This generator creates ajax and html controllers, for linking the user to the agent"

  source_root File.expand_path("../templates", __FILE__)
  
  argument :file_name, :type => :string
  class_option :devise, :type => :boolean, :default => true, :desc => "Include Devise (requires AR)."

  #Adds in the lib/action directory a "file_name action" rb class template
  #Adds in the test/unit directory  a "file_name action" unit test template
  def generate_controller

    controller_path ="app/controllers/#{file_name}_controller.rb"

    template "agent_controller.rb.erb", controller_path

    route("match '#{file_name}', :to => '#{file_name}#execute', :via => [:post]")
  end

  def generate_view
    template "agent_view.rb.erb", "app/views/#{file_name}/execute.html.erb"
  end

end