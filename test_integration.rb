#!/usr/bin/env ruby

# Simple integration test for eval hooks functionality
puts "Testing eval hooks integration..."

# Load the eval hooks classes
require_relative 'lib/devcycle-ruby-server-sdk/eval_hooks_runner'
require_relative 'lib/devcycle-ruby-server-sdk/models/eval_hook'
require_relative 'lib/devcycle-ruby-server-sdk/models/eval_hook_context'

# Test the eval hooks classes work together
puts "\n1. Testing EvalHooksRunner with EvalHook..."

runner = DevCycle::EvalHooksRunner.new
hook = DevCycle::EvalHook.new(
  before: ->(context) {
    puts "  Before hook called with key: #{context.key}"
    context
  },
  after: ->(context) {
    puts "  After hook called with key: #{context.key}"
  },
  error: ->(context, error) {
    puts "  Error hook called with error: #{error.message}"
  },
  on_finally: ->(context) {
    puts "  Finally hook called with key: #{context.key}"
  }
)

runner.add_hook(hook)

context = DevCycle::HookContext.new(
  key: 'test-key',
  user: 'test-user',
  default_value: 'test-default'
)

puts "Running hooks..."
runner.run_before_hooks(context)
runner.run_after_hooks(context)
runner.run_finally_hooks(context)

puts "\n2. Testing error handling..."
test_error = StandardError.new('Test error')
runner.run_error_hooks(context, test_error)

puts "\n3. Testing multiple hooks..."
runner.clear_hooks

hook1 = DevCycle::EvalHook.new(
  before: ->(context) {
    puts "  Hook1 before"
    context
  },
  after: ->(context) {
    puts "  Hook1 after"
  }
)

hook2 = DevCycle::EvalHook.new(
  before: ->(context) {
    puts "  Hook2 before"
    context
  },
  after: ->(context) {
    puts "  Hook2 after"
  }
)

runner.add_hook(hook1)
runner.add_hook(hook2)

puts "Running multiple hooks..."
runner.run_before_hooks(context)
runner.run_after_hooks(context)

puts "\nIntegration test completed successfully!" 