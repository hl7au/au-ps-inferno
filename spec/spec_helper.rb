# frozen_string_literal: true

# Default RSpec bootstrap: WebMock, Faraday, optional SimpleCov — no full Inferno app.
# For specs that need Inferno + DB + FactoryBot, add at the top of the spec file:
#   require_relative 'spec_helper_inferno'

$VERBOSE = nil

ENV['APP_ENV'] ||= 'test'

require_relative 'spec_helper_validator_helpers'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.example_status_persistence_file_path = 'spec/examples.txt'

  config.disable_monkey_patching!

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.order = :random
  Kernel.srand config.seed

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
end
