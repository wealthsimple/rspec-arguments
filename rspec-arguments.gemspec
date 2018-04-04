# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/arguments/version'

Gem::Specification.new do |spec|
  spec.name          = 'rspec-arguments'
  spec.version       = RSpec::Arguments::VERSION
  spec.authors       = ['Marco Costa']
  spec.email         = ['marco@marcotc.com']

  spec.summary       = ' Parameter passing to implicit RSpec subjects.'
  spec.description   = <<~DESC
    Allows parameter passing to implicit RSpec subjects.
    It also adds support for implicit method calls on described_class instances.
  DESC
  spec.homepage      = 'https://github.com/wealthsimple/rspec-arguments'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.4'

  spec.add_dependency 'rspec-core', '~> 3'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'bundler-audit'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '0.49.1' # Temporarily necessary to avoid breaking ws-style
  spec.add_development_dependency 'ws-style'
end
