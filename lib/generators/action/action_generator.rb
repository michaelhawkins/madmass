class ActionGenerator < Rails::Generators::NamedBase

  desc "This generator creates an action file at lib/actions"

  source_root File.expand_path("../templates", __FILE__)

  #Adds in the action directory a "file_name action" rb class template
  def render_action_file
    template "action.rb.erb", "lib/actions/#{file_name}_action.rb"
  end

end