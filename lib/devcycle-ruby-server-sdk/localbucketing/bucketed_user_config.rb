# frozen_string_literal: true


module DevCycle
  class Environment
    attr_accessor :id
    attr_accessor :key
  end

  class FeatureVariationMap
    attr_accessor :the_6216422850294_da359385_e8_b
  end

  class FeaturesTest
    attr_accessor :id
    attr_accessor :test_type
    attr_accessor :key
    attr_accessor :variation
    attr_accessor :variation_name
    attr_accessor :variation_key
  end

  class Features
    attr_accessor :features_test
  end

  class EdgeDB
    attr_accessor :enabled
  end

  class Colors
    attr_accessor :primary
    attr_accessor :secondary
  end

  class OptIn
    attr_accessor :enabled
    attr_accessor :title
    attr_accessor :description
    attr_accessor :image_url
    attr_accessor :colors
  end

  class Settings
    attr_accessor :edge_db
    attr_accessor :opt_in
  end

  class Project
    attr_accessor :id
    attr_accessor :key
    attr_accessor :a0_organization
    attr_accessor :settings
  end

  class VariableVariationMapTest
    attr_accessor :feature
    attr_accessor :variation
  end

  class VariableVariationMap
    attr_accessor :variable_variation_map_test
  end

  class VariablesTest
    attr_accessor :id
    attr_accessor :test_type
    attr_accessor :key
    attr_accessor :value
  end

  class Variables
    attr_accessor :variables_test
  end

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
      @feature_var_map = feature_var_map
      @variable_var_map = variable_var_map
      @variables = variables
      @known_variable_keys = known_variable_keys
    end
  end

end