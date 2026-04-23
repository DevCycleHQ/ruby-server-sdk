module DevCycle
  class HookContext
    # The key of the variable being evaluated
    attr_accessor :key

    # The user for whom the variable is being evaluated
    attr_accessor :user

    # The default value for the variable
    attr_accessor :default_value

    # Initializes the object
    # @param [String] key The key of the variable being evaluated
    # @param [DevCycle::User] user The user for whom the variable is being evaluated
    # @param [Object] default_value The default value for the variable
    def initialize(key:, user:, default_value:)
      @key = key
      @user = user
      @default_value = default_value
    end
  end
end
