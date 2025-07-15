module DevCycle
  class EvalHook
    # Callback to be executed before evaluation
    attr_accessor :before

    # Callback to be executed after evaluation
    attr_accessor :after

    # Callback to be executed finally (always runs)
    attr_accessor :on_finally

    # Callback to be executed on error
    attr_accessor :error

    # Initializes the object with optional callback functions
    # @param [Hash] callbacks Callback functions in the form of hash
    # @option callbacks [Proc, nil] :before Callback to execute before evaluation
    # @option callbacks [Proc, nil] :after Callback to execute after evaluation
    # @option callbacks [Proc, nil] :on_finally Callback to execute finally (always runs)
    # @option callbacks [Proc, nil] :error Callback to execute on error
    def initialize(callbacks = {})
      @before = callbacks[:before]
      @after = callbacks[:after]
      @on_finally = callbacks[:on_finally]
      @error = callbacks[:error]
    end
  end
end
