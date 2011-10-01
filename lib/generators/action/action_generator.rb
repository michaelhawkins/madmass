
class ActionGenerator < Rails::Generators::NamedBase

  desc "This generator creates an action file at lib/actions"

  source_root File.expand_path("../templates", __FILE__)

  #Adds in the lib/action directory a "file_name action" rb class template
  #Adds in the test/unit directory  a "file_name action" unit test template
  def render_action_files
    template "action.rb.erb", "lib/actions/#{file_name}_action.rb"
    template "action_unit_test.rb.erb", "test/unit/#{file_name}_action_test.rb"
  end

end