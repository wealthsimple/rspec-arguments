# frozen_string_literal: true

require 'rspec/support'

RSpec::Support.define_optimized_require_for_rspec(:arguments) { |f| require_relative(f) }

%w[
  arguments
  example_group
  monkey_patcher
  version
].each { |file| RSpec::Support.require_rspec_arguments(file) }

RSpec.configure do |c|
  c.extend RSpec::Arguments::ExampleGroup
  c.include RSpec::Arguments::MonkeyPatcher
  c.backtrace_exclusion_patterns << %r(/lib/rspec/arguments)
end
