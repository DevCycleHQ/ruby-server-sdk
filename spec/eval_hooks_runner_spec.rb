require 'spec_helper'
require 'devcycle-ruby-server-sdk/eval_hooks_runner'

describe DevCycle::EvalHooksRunner do
  let(:test_context) { DevCycle::HookContext.new(key: 'test-key', user: 'test-user', default_value: 'test-default') }

  describe 'initialization' do
    it 'initializes with empty hooks array' do
      runner = DevCycle::EvalHooksRunner.new
      expect(runner.eval_hooks).to be_empty
    end

    it 'initializes with provided hooks' do
      hook = DevCycle::EvalHook.new
      runner = DevCycle::EvalHooksRunner.new([hook])
      expect(runner.eval_hooks).to include(hook)
    end
  end

  describe '#add_hook' do
    it 'adds a hook to the runner' do
      runner = DevCycle::EvalHooksRunner.new
      hook = DevCycle::EvalHook.new
      
      runner.add_hook(hook)
      expect(runner.eval_hooks).to include(hook)
    end

    it 'can add multiple hooks' do
      runner = DevCycle::EvalHooksRunner.new
      hook1 = DevCycle::EvalHook.new
      hook2 = DevCycle::EvalHook.new
      
      runner.add_hook(hook1)
      runner.add_hook(hook2)
      
      expect(runner.eval_hooks).to include(hook1, hook2)
      expect(runner.eval_hooks.length).to eq(2)
    end
  end

  describe '#clear_hooks' do
    it 'removes all hooks from the runner' do
      runner = DevCycle::EvalHooksRunner.new
      hook = DevCycle::EvalHook.new
      
      runner.add_hook(hook)
      expect(runner.eval_hooks).not_to be_empty
      
      runner.clear_hooks
      expect(runner.eval_hooks).to be_empty
    end
  end

  describe '#run_before_hooks' do
    it 'runs before hooks in order' do
      execution_order = []
      runner = DevCycle::EvalHooksRunner.new
      
      hook1 = DevCycle::EvalHook.new(
        before: ->(context) {
          execution_order << 'hook1'
          context
        }
      )
      
      hook2 = DevCycle::EvalHook.new(
        before: ->(context) {
          execution_order << 'hook2'
          context
        }
      )
      
      runner.add_hook(hook1)
      runner.add_hook(hook2)
      
      result = runner.run_before_hooks(test_context)
      
      expect(execution_order).to eq(['hook1', 'hook2'])
      expect(result).to eq(test_context)
    end

    it 'returns modified context from before hook' do
      runner = DevCycle::EvalHooksRunner.new
      modified_context = DevCycle::HookContext.new(key: 'modified', user: 'modified-user', default_value: 'modified-default')
      
      hook = DevCycle::EvalHook.new(
        before: ->(context) {
          modified_context
        }
      )
      
      runner.add_hook(hook)
      result = runner.run_before_hooks(test_context)
      
      expect(result).to eq(modified_context)
    end

    it 'handles hooks without before callbacks' do
      runner = DevCycle::EvalHooksRunner.new
      hook = DevCycle::EvalHook.new # No before callback
      
      runner.add_hook(hook)
      result = runner.run_before_hooks(test_context)
      
      expect(result).to eq(test_context)
    end

    it 'raises BeforeHookError when a before hook raises an error' do
      runner = DevCycle::EvalHooksRunner.new
      hook1_called = false
      
      hook1 = DevCycle::EvalHook.new(
        before: ->(context) {
          hook1_called = true
          raise StandardError, 'Hook 1 error'
        }
      )
      
      hook2 = DevCycle::EvalHook.new(
        before: ->(context) {
          # This should not be called because hook1 raises an error
          context
        }
      )
      
      runner.add_hook(hook1)
      runner.add_hook(hook2)
      
      expect { runner.run_before_hooks(test_context) }.to raise_error(DevCycle::BeforeHookError, /Hook 1 error/)
      expect(hook1_called).to be true
    end
  end

  describe '#run_after_hooks' do
    it 'runs after hooks in order' do
      execution_order = []
      runner = DevCycle::EvalHooksRunner.new
      
      hook1 = DevCycle::EvalHook.new(
        after: ->(context) {
          execution_order << 'hook1'
        }
      )
      
      hook2 = DevCycle::EvalHook.new(
        after: ->(context) {
          execution_order << 'hook2'
        }
      )
      
      runner.add_hook(hook1)
      runner.add_hook(hook2)
      
      runner.run_after_hooks(test_context)
      
      expect(execution_order).to eq(['hook1', 'hook2'])
    end

    it 'handles hooks without after callbacks' do
      runner = DevCycle::EvalHooksRunner.new
      hook = DevCycle::EvalHook.new # No after callback
      
      expect { runner.run_after_hooks(test_context) }.not_to raise_error
    end

    it 'raises AfterHookError when an after hook raises an error' do
      runner = DevCycle::EvalHooksRunner.new
      hook1_called = false
      
      hook1 = DevCycle::EvalHook.new(
        after: ->(context) {
          hook1_called = true
          raise StandardError, 'Hook 1 error'
        }
      )
      
      hook2 = DevCycle::EvalHook.new(
        after: ->(context) {
          # This should not be called because hook1 raises an error
        }
      )
      
      runner.add_hook(hook1)
      runner.add_hook(hook2)
      
      expect { runner.run_after_hooks(test_context) }.to raise_error(DevCycle::AfterHookError, /Hook 1 error/)
      expect(hook1_called).to be true
    end
  end

  describe '#run_error_hooks' do
    it 'runs error hooks with context and error' do
      runner = DevCycle::EvalHooksRunner.new
      error_hook_called = false
      received_error = nil
      
      hook = DevCycle::EvalHook.new(
        error: ->(context, error) {
          error_hook_called = true
          received_error = error
        }
      )
      
      runner.add_hook(hook)
      test_error = StandardError.new('Test error')
      
      runner.run_error_hooks(test_context, test_error)
      
      expect(error_hook_called).to be true
      expect(received_error).to eq(test_error)
    end

    it 'runs multiple error hooks in order' do
      execution_order = []
      runner = DevCycle::EvalHooksRunner.new
      
      hook1 = DevCycle::EvalHook.new(
        error: ->(context, error) {
          execution_order << 'hook1'
        }
      )
      
      hook2 = DevCycle::EvalHook.new(
        error: ->(context, error) {
          execution_order << 'hook2'
        }
      )
      
      runner.add_hook(hook1)
      runner.add_hook(hook2)
      
      test_error = StandardError.new('Test error')
      runner.run_error_hooks(test_context, test_error)
      
      expect(execution_order).to eq(['hook1', 'hook2'])
    end

    it 'handles hooks without error callbacks' do
      runner = DevCycle::EvalHooksRunner.new
      hook = DevCycle::EvalHook.new # No error callback
      
      test_error = StandardError.new('Test error')
      expect { runner.run_error_hooks(test_context, test_error) }.not_to raise_error
    end

    it 'continues execution when an error hook raises an error' do
      runner = DevCycle::EvalHooksRunner.new
      hook1_called = false
      hook2_called = false
      
      hook1 = DevCycle::EvalHook.new(
        error: ->(context, error) {
          hook1_called = true
          raise StandardError, 'Error hook error'
        }
      )
      
      hook2 = DevCycle::EvalHook.new(
        error: ->(context, error) {
          hook2_called = true
        }
      )
      
      runner.add_hook(hook1)
      runner.add_hook(hook2)
      
      test_error = StandardError.new('Test error')
      runner.run_error_hooks(test_context, test_error)
      
      expect(hook1_called).to be true
      expect(hook2_called).to be true
    end
  end

  describe '#run_finally_hooks' do
    it 'runs finally hooks in order' do
      execution_order = []
      runner = DevCycle::EvalHooksRunner.new
      
      hook1 = DevCycle::EvalHook.new(
        on_finally: ->(context) {
          execution_order << 'hook1'
        }
      )
      
      hook2 = DevCycle::EvalHook.new(
        on_finally: ->(context) {
          execution_order << 'hook2'
        }
      )
      
      runner.add_hook(hook1)
      runner.add_hook(hook2)
      
      runner.run_finally_hooks(test_context)
      
      expect(execution_order).to eq(['hook1', 'hook2'])
    end

    it 'handles hooks without finally callbacks' do
      runner = DevCycle::EvalHooksRunner.new
      hook = DevCycle::EvalHook.new # No finally callback
      
      expect { runner.run_finally_hooks(test_context) }.not_to raise_error
    end

    it 'continues execution when a finally hook raises an error' do
      runner = DevCycle::EvalHooksRunner.new
      hook1_called = false
      hook2_called = false
      
      hook1 = DevCycle::EvalHook.new(
        on_finally: ->(context) {
          hook1_called = true
          raise StandardError, 'Finally hook error'
        }
      )
      
      hook2 = DevCycle::EvalHook.new(
        on_finally: ->(context) {
          hook2_called = true
        }
      )
      
      runner.add_hook(hook1)
      runner.add_hook(hook2)
      
      runner.run_finally_hooks(test_context)
      
      expect(hook1_called).to be true
      expect(hook2_called).to be true
    end
  end
end

describe DevCycle::EvalHook do
  describe 'initialization' do
    it 'initializes with no callbacks' do
      hook = DevCycle::EvalHook.new
      expect(hook.before).to be_nil
      expect(hook.after).to be_nil
      expect(hook.on_finally).to be_nil
      expect(hook.error).to be_nil
    end

    it 'initializes with provided callbacks' do
      before_callback = ->(context) { context }
      after_callback = ->(context) { }
      error_callback = ->(context, error) { }
      finally_callback = ->(context) { }
      
      hook = DevCycle::EvalHook.new(
        before: before_callback,
        after: after_callback,
        error: error_callback,
        on_finally: finally_callback
      )
      
      expect(hook.before).to eq(before_callback)
      expect(hook.after).to eq(after_callback)
      expect(hook.error).to eq(error_callback)
      expect(hook.on_finally).to eq(finally_callback)
    end

    it 'initializes with partial callbacks' do
      before_callback = ->(context) { context }
      
      hook = DevCycle::EvalHook.new(before: before_callback)
      
      expect(hook.before).to eq(before_callback)
      expect(hook.after).to be_nil
      expect(hook.on_finally).to be_nil
      expect(hook.error).to be_nil
    end
  end
end

describe DevCycle::HookContext do
  describe 'initialization' do
    it 'initializes with required parameters' do
      user = { user_id: 'test-user' }
      context = DevCycle::HookContext.new(
        key: 'test-key',
        user: user,
        default_value: 'test-default'
      )
      
      expect(context.key).to eq('test-key')
      expect(context.user).to eq(user)
      expect(context.default_value).to eq('test-default')
    end

    it 'allows modification of attributes' do
      context = DevCycle::HookContext.new(
        key: 'original-key',
        user: 'original-user',
        default_value: 'original-default'
      )
      
      context.key = 'modified-key'
      context.user = 'modified-user'
      context.default_value = 'modified-default'
      
      expect(context.key).to eq('modified-key')
      expect(context.user).to eq('modified-user')
      expect(context.default_value).to eq('modified-default')
    end
  end
end 