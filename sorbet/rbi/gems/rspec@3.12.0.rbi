# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `rspec` gem.
# Please instead update this file by running `bin/tapioca gem rspec`.

# source://rspec//lib/rspec/version.rb#1
module RSpec
  class << self
    # source://rspec-core/3.12.0/lib/rspec/core.rb#70
    def clear_examples; end

    # source://rspec-core/3.12.0/lib/rspec/core.rb#85
    def configuration; end

    # source://rspec-core/3.12.0/lib/rspec/core.rb#49
    def configuration=(_arg0); end

    # source://rspec-core/3.12.0/lib/rspec/core.rb#97
    def configure; end

    # source://rspec-core/3.12.0/lib/rspec/core.rb#194
    def const_missing(name); end

    # source://rspec-core/3.12.0/lib/rspec/core/dsl.rb#42
    def context(*args, &example_group_block); end

    # source://rspec-core/3.12.0/lib/rspec/core.rb#122
    def current_example; end

    # source://rspec-core/3.12.0/lib/rspec/core.rb#128
    def current_example=(example); end

    # source://rspec-core/3.12.0/lib/rspec/core.rb#154
    def current_scope; end

    # source://rspec-core/3.12.0/lib/rspec/core.rb#134
    def current_scope=(scope); end

    # source://rspec-core/3.12.0/lib/rspec/core/dsl.rb#42
    def describe(*args, &example_group_block); end

    # source://rspec-core/3.12.0/lib/rspec/core/dsl.rb#42
    def example_group(*args, &example_group_block); end

    # source://rspec-core/3.12.0/lib/rspec/core/dsl.rb#42
    def fcontext(*args, &example_group_block); end

    # source://rspec-core/3.12.0/lib/rspec/core/dsl.rb#42
    def fdescribe(*args, &example_group_block); end

    # source://rspec-core/3.12.0/lib/rspec/core.rb#58
    def reset; end

    # source://rspec-core/3.12.0/lib/rspec/core/shared_example_group.rb#110
    def shared_context(name, *args, &block); end

    # source://rspec-core/3.12.0/lib/rspec/core/shared_example_group.rb#110
    def shared_examples(name, *args, &block); end

    # source://rspec-core/3.12.0/lib/rspec/core/shared_example_group.rb#110
    def shared_examples_for(name, *args, &block); end

    # source://rspec-core/3.12.0/lib/rspec/core.rb#160
    def world; end

    # source://rspec-core/3.12.0/lib/rspec/core.rb#49
    def world=(_arg0); end

    # source://rspec-core/3.12.0/lib/rspec/core/dsl.rb#42
    def xcontext(*args, &example_group_block); end

    # source://rspec-core/3.12.0/lib/rspec/core/dsl.rb#42
    def xdescribe(*args, &example_group_block); end
  end
end

# source://rspec-core/3.12.0/lib/rspec/core.rb#187
RSpec::MODULES_TO_AUTOLOAD = T.let(T.unsafe(nil), Hash)

# source://rspec-core/3.12.0/lib/rspec/core/shared_context.rb#54
RSpec::SharedContext = RSpec::Core::SharedContext

# source://rspec//lib/rspec/version.rb#2
module RSpec::Version; end

# source://rspec//lib/rspec/version.rb#3
RSpec::Version::STRING = T.let(T.unsafe(nil), String)
