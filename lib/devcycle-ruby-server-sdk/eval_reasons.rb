module DevCycle
  # Default reasons for evaluation failures
  module DEFAULT_REASONS
    MISSING_CONFIG = 'MISSING_CONFIG'
    MISSING_VARIABLE = 'MISSING_VARIABLE'
    MISSING_FEATURE = 'MISSING_FEATURE'
    MISSING_VARIATION = 'MISSING_VARIATION'
    MISSING_VARIABLE_FOR_VARIATION = 'MISSING_VARIABLE_FOR_VARIATION'
    USER_NOT_IN_ROLLOUT = 'USER_NOT_IN_ROLLOUT'
    USER_NOT_TARGETED = 'USER_NOT_TARGETED'
    INVALID_VARIABLE_TYPE = 'INVALID_VARIABLE_TYPE'
    UNKNOWN = 'UNKNOWN'
    DEFAULT = 'DEFAULT'
  end

  # Evaluation reasons for successful evaluations
  module EVAL_REASONS
    TARGETING_MATCH = 'TARGETING_MATCH'
    SPLIT = 'SPLIT'
    DEFAULT = 'DEFAULT'
    DISABLED = 'DISABLED'
    ERROR = 'ERROR'
    OVERRIDE = 'OVERRIDE'
    OPT_IN = 'OPT_IN'
  end

  # Detailed evaluation reason descriptions
  module EVAL_REASON_DETAILS
    # All Users
    ALL_USERS = 'All Users'
    # Audiences
    AUDIENCE_MATCH = 'Audience Match'
    NOT_IN_AUDIENCE = 'Not in Audience'
    # Opt-In
    OPT_IN = 'Opt-In'
    NOT_OPTED_IN = 'Not Opt-In'
    # Overrides
    OVERRIDE = 'Override'
    # Split details
    RANDOM_DISTRIBUTION = 'Random Distribution'
    ROLLOUT = 'Rollout'
    # User Specific
    USER_ID = 'User ID'
    EMAIL = 'Email'
    COUNTRY = 'Country'
    PLATFORM = 'Platform'
    PLATFORM_VERSION = 'Platform Version'
    APP_VERSION = 'App Version'
    DEVICE_MODEL = 'Device Model'
    CUSTOM_DATA = 'Custom Data'
    # Error cases
    ERROR = 'Error'
    DEFAULT = 'Default'
    UNKNOWN = 'Unknown'
  end

  # Default reason details
  module DEFAULT_REASON_DETAILS
    MISSING_CONFIG = 'Missing Config'
    MISSING_VARIABLE = 'Missing Variable'
    MISSING_FEATURE = 'Missing Feature'
    MISSING_VARIATION = 'Missing Variation'
    MISSING_VARIABLE_FOR_VARIATION = 'Missing Variable for Variation'
    USER_NOT_IN_ROLLOUT = 'User Not in Rollout'
    USER_NOT_TARGETED = 'User Not Targeted'
    INVALID_VARIABLE_TYPE = 'Invalid Variable Type'
    TYPE_MISMATCH = 'Variable Type Mismatch'
    UNKNOWN = 'Unknown'
    ERROR = 'Error'
  end
end
