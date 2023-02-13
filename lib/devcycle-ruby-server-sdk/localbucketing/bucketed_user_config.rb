module DevCycle

  class BucketedUserConfig
    attr_accessor :project
    attr_accessor :environment
    attr_accessor :features
    attr_accessor :feature_variation_map
    attr_accessor :variable_variation_map
    attr_accessor :variables
    attr_accessor :known_variable_keys

    def initialize(project, environment, features, feature_var_map, variable_var_map, variables, known_variable_keys)
      @project = project
      @environment = environment
      @features = features
      @feature_variation_map = feature_var_map
      @variable_variation_map = variable_var_map
      @variables = variables
      @known_variable_keys = known_variable_keys
    end
  end

end