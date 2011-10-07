class PerceptStrategyGenerator < Rails::Generators::NamedBase

  desc "This generator creates a client strategy that respond to a named percept"

  source_root File.expand_path("../templates", __FILE__)

  #Adds in the app/assets/javascripts/madmass/ directory a "file_name percept_strategy" js
  def generate_strategy
    template "percept_strategy.js.erb", "app/assets/javascripts/madmass/#{file_name}_percept_strategy.js"
  end

end