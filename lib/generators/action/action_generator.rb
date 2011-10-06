class ActionGenerator < Rails::Generators::NamedBase

  desc "This generator creates an action file at lib/actions and a test file at test/unit"

  source_root File.expand_path("../templates", __FILE__)

  #Adds in the lib/action directory a "file_name action" rb class template
  def generate_action
    template "action.rb.erb", "lib/actions/#{file_name}_action.rb"
  end

  #Adds in the test/unit directory  a "file_name action" unit test template
  def generate_test
    template "action_unit_test.rb.erb", "test/unit/#{file_name}_action_test.rb"
  end

end