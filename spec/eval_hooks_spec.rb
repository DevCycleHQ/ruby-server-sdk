require 'spec_helper'

describe DevCycle::Client do
  let(:test_user) { DevCycle::User.new(user_id: 'test-user', email: 'test@example.com') }
  let(:test_key) { 'test-variable' }
  let(:test_default) { 'default-value' }
  let(:options) { DevCycle::Options.new }
  
  # Use unique SDK keys for each test to avoid WASM initialization conflicts
  let(:valid_sdk_key) { "server-test-key-#{SecureRandom.hex(4)}" }
  let(:client) { DevCycle::Client.new(valid_sdk_key, options) }

  after(:each) do
    client.close if client.respond_to?(:close)
  end

  describe 'eval hooks functionality' do
    context 'hook management' do
      it 'initializes with an empty eval hooks runner' do
        expect(client.instance_variable_get(:@eval_hooks_runner)).to be_a(DevCycle::EvalHooksRunner)
        expect(client.instance_variable_get(:@eval_hooks_runner).eval_hooks).to be_empty
      end

      it 'can add eval hooks' do
        hook = DevCycle::EvalHook.new
        client.add_eval_hook(hook)
        expect(client.instance_variable_get(:@eval_hooks_runner).eval_hooks).to include(hook)
      end

      it 'can clear eval hooks' do
        hook = DevCycle::EvalHook.new
        client.add_eval_hook(hook)
        expect(client.instance_variable_get(:@eval_hooks_runner).eval_hooks).not_to be_empty
        
        client.clear_eval_hooks
        expect(client.instance_variable_get(:@eval_hooks_runner).eval_hooks).to be_empty
      end
    end

    context 'variable evaluation with hooks' do
      it 'runs before hooks before variable evaluation' do
        before_hook_called = false
        hook = DevCycle::EvalHook.new(
          before: ->(context) {
            before_hook_called = true
            expect(context.key).to eq(test_key)
            expect(context.user).to eq(test_user)
            expect(context.default_value).to eq(test_default)
            context
          }
        )
        client.add_eval_hook(hook)

        result = client.variable(test_user, test_key, test_default)
        expect(before_hook_called).to be true
        expect(result.isDefaulted).to be true
        expect(result.value).to eq(test_default)
      end

      it 'runs after hooks after successful variable evaluation' do
        after_hook_called = false
        hook = DevCycle::EvalHook.new(
          after: ->(context) {
            after_hook_called = true
            expect(context.key).to eq(test_key)
            expect(context.user).to eq(test_user)
            expect(context.default_value).to eq(test_default)
          }
        )
        client.add_eval_hook(hook)

        result = client.variable(test_user, test_key, test_default)
        expect(after_hook_called).to be true
        expect(result.isDefaulted).to be true
        expect(result.value).to eq(test_default)
      end

      it 'runs error hooks when variable evaluation fails' do
        error_hook_called = false
        hook = DevCycle::EvalHook.new(
          error: ->(context, error) {
            error_hook_called = true
            expect(context.key).to eq(test_key)
            expect(context.user).to eq(test_user)
            expect(context.default_value).to eq(test_default)
          }
        )
        client.add_eval_hook(hook)

        # Force an error by making determine_variable_type raise an error
        allow(client).to receive(:determine_variable_type).and_raise(StandardError, 'Variable type error')

        client.variable(test_user, test_key, test_default)
        expect(error_hook_called).to be true
      end

      it 'runs finally hooks regardless of success or failure' do
        finally_hook_called = false
        hook = DevCycle::EvalHook.new(
          on_finally: ->(context) {
            finally_hook_called = true
            expect(context.key).to eq(test_key)
            expect(context.user).to eq(test_user)
            expect(context.default_value).to eq(test_default)
          }
        )
        client.add_eval_hook(hook)

        result = client.variable(test_user, test_key, test_default)
        expect(finally_hook_called).to be true
        expect(result.isDefaulted).to be true
        expect(result.value).to eq(test_default)
      end

      it 'skips after hooks when before hook raises an error' do
        before_hook_called = false
        after_hook_called = false
        error_hook_called = false
        finally_hook_called = false

        hook = DevCycle::EvalHook.new(
          before: ->(context) {
            before_hook_called = true
            raise StandardError, 'Before hook error'
          },
          after: ->(context) {
            after_hook_called = true
          },
          error: ->(context, error) {
            error_hook_called = true
            expect(error).to be_a(StandardError)
            expect(error.message).to include('Before hook error')
          },
          on_finally: ->(context) {
            finally_hook_called = true
          }
        )
        client.add_eval_hook(hook)

        client.variable(test_user, test_key, test_default)
        expect(before_hook_called).to be true
        expect(after_hook_called).to be false
        expect(error_hook_called).to be true
        expect(finally_hook_called).to be true
      end

      it 'runs multiple hooks in order' do
        execution_order = []
        
        hook1 = DevCycle::EvalHook.new(
          before: ->(context) {
            execution_order << 'hook1_before'
            context
          },
          after: ->(context) {
            execution_order << 'hook1_after'
          },
          on_finally: ->(context) {
            execution_order << 'hook1_finally'
          }
        )

        hook2 = DevCycle::EvalHook.new(
          before: ->(context) {
            execution_order << 'hook2_before'
            context
          },
          after: ->(context) {
            execution_order << 'hook2_after'
          },
          on_finally: ->(context) {
            execution_order << 'hook2_finally'
          }
        )

        client.add_eval_hook(hook1)
        client.add_eval_hook(hook2)

        result = client.variable(test_user, test_key, test_default)
        
        expect(execution_order).to eq([
          'hook1_before', 'hook2_before',
          'hook1_after', 'hook2_after',
          'hook1_finally', 'hook2_finally'
        ])
        expect(result.isDefaulted).to be true
        expect(result.value).to eq(test_default)
      end

      it 'allows before hooks to modify context' do
        modified_context = nil
        hook = DevCycle::EvalHook.new(
          before: ->(context) {
            # Modify the context
            context.key = 'modified-key'
            context.user = DevCycle::User.new(user_id: 'modified-user', email: 'modified@example.com')
            context
          },
          after: ->(context) {
            modified_context = context
          }
        )
        client.add_eval_hook(hook)

        result = client.variable(test_user, test_key, test_default)
        
        expect(modified_context.key).to eq('modified-key')
        expect(modified_context.user).to eq(DevCycle::User.new(user_id: 'modified-user', email: 'modified@example.com'))
        expect(result.isDefaulted).to be true
        expect(result.value).to eq(test_default)
      end

      it 'works with different variable types' do
        # Test with boolean default
        boolean_hook_called = false
        boolean_hook = DevCycle::EvalHook.new(
          after: ->(context) {
            boolean_hook_called = true
          }
        )
        client.add_eval_hook(boolean_hook)

        boolean_result = client.variable(test_user, 'boolean-test', true)
        expect(boolean_hook_called).to be true
        expect(boolean_result.isDefaulted).to be true
        expect(boolean_result.value).to eq(true)

        # Test with number default
        number_hook_called = false
        number_hook = DevCycle::EvalHook.new(
          after: ->(context) {
            number_hook_called = true
          }
        )
        client.add_eval_hook(number_hook)

        number_result = client.variable(test_user, 'number-test', 42)
        expect(number_hook_called).to be true
        expect(number_result.isDefaulted).to be true
        expect(number_result.value).to eq(42)
      end

    end
  end
end 