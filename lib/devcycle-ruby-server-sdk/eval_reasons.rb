module DevCycle

  # Default reasons for evaluation failures
  module DEFAULT_REASONS
    USER_NOT_TARGETED = 'USER_NOT_TARGETED'
  end
  # Evaluation reasons for successful evaluations
  module EVAL_REASONS
    DEFAULT = 'DEFAULT'
    ERROR = 'ERROR'
  end

  # Default reason details
  module DEFAULT_REASON_DETAILS
    MISSING_CONFIG = 'Missing Config'
    USER_NOT_TARGETED = 'User Not Targeted'
  end
end
