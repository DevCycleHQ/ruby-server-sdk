require 'devcycle-ruby-server-sdk/models/eval_hook'
require 'devcycle-ruby-server-sdk/models/eval_hook_context'

module DevCycle
  # Custom error raised when a before hook fails
  class BeforeHookError < StandardError
    attr_reader :original_error, :hook_context

    def initialize(message = nil, original_error = nil, hook_context = nil)
      super(message || "Before hook execution failed")
      @original_error = original_error
      @hook_context = hook_context
    end

    def to_s
      msg = super
      msg += "\nOriginal error: #{@original_error.message}" if @original_error
      msg
    end
  end

  # Custom error raised when an after hook fails
  class AfterHookError < StandardError
    attr_reader :original_error, :hook_context

    def initialize(message = nil, original_error = nil, hook_context = nil)
      super(message || "After hook execution failed")
      @original_error = original_error
      @hook_context = hook_context
    end

    def to_s
      msg = super
      msg += "\nOriginal error: #{@original_error.message}" if @original_error
      msg
    end
  end

  class EvalHooksRunner
    # @return [Array<EvalHook>] Array of eval hooks to run
    attr_reader :eval_hooks

    # Initializes the EvalHooksRunner with an optional array of eval hooks
    # @param [Array<EvalHook>, nil] eval_hooks Array of eval hooks to run
    def initialize(eval_hooks = [])
      @eval_hooks = eval_hooks || []
    end

    # Runs all before hooks with the given context
    # @param [HookContext] context The context to pass to the hooks
    # @return [HookContext] The potentially modified context
    # @raise [BeforeHookError] when a before hook fails
    def run_before_hooks(context)
      current_context = context
      
      @eval_hooks.each do |hook|
        next unless hook.before

        begin
          result = hook.before.call(current_context)
          # If the hook returns a new context, use it for subsequent hooks
          current_context = result if result.is_a?(DevCycle::HookContext)
        rescue => e
          # Raise BeforeHookError to allow client to handle and skip after hooks
          raise BeforeHookError.new(e.message, e, current_context)
        end
      end
      
      current_context
    end

    # Runs all after hooks with the given context
    # @param [HookContext] context The context to pass to the hooks
    # @return [void]
    # @raise [AfterHookError] when an after hook fails
    def run_after_hooks(context)
      @eval_hooks.each do |hook|
        next unless hook.after

        begin
          hook.after.call(context)
        rescue => e
          # Log error but continue with next hook
          raise AfterHookError.new(e.message, e, context)
        end
      end
    end

    # Runs all finally hooks with the given context
    # @param [HookContext] context The context to pass to the hooks
    # @return [void]
    def run_finally_hooks(context)
      @eval_hooks.each do |hook|
        next unless hook.on_finally

        begin
          hook.on_finally.call(context)
        rescue => e
          # Log error but don't re-raise to prevent blocking evaluation
          warn "Error in finally hook: #{e.message}"
        end
      end
    end

    # Runs all error hooks with the given context and error
    # @param [HookContext] context The context to pass to the hooks
    # @param [Exception] error The error that occurred
    # @return [void]
    def run_error_hooks(context, error)
      @eval_hooks.each do |hook|
        next unless hook.error

        begin
          hook.error.call(context, error)
        rescue => e
          # Log error but don't re-raise to prevent blocking evaluation
          warn "Error in error hook: #{e.message}"
        end
      end
    end

    # Adds an eval hook to the runner
    # @param [EvalHook] eval_hook The eval hook to add
    # @return [void]
    def add_hook(eval_hook)
      @eval_hooks << eval_hook
    end

    # Clears all eval hooks from the runner
    # @return [void]
    def clear_hooks
      @eval_hooks.clear
    end
  end
end
