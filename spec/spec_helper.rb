ENV['RUBYOPT'] = 'W0'

lib = File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rspec'
require 'rspec/mocks'
require 'rspec/expectations'
require 'pry-byebug'

if ARGV.empty?
  require 'simplecov'

  SimpleCov.start do
    add_filter 'spec/'
  end
end

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |spec|
  spec.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  spec.raise_errors_for_deprecations!
  spec.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
