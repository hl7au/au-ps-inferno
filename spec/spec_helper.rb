# frozen_string_literal: true

if ENV['COVERAGE'] == '1'
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
end

# Hide deprecation warnings
$VERBOSE = nil

ENV['APP_ENV'] ||= 'test'

require 'database_cleaner/sequel'
require 'pry'
require 'pry-byebug'

require 'webmock/rspec'
WebMock.disable_net_connect!

require 'factory_bot'

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

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    FactoryBot.find_definitions
  end

  config.around do |example|
    DatabaseCleaner.cleaning { example.run }
  end

  config.include FactoryBot::Syntax::Methods
end

require 'inferno/config/application'
require 'inferno/utils/migration'
Inferno::Utils::Migration.new.run

require 'inferno'
Inferno::Application.finalize!

require Inferno::SpecSupport::FACTORY_BOT_SUPPORT_PATH

FactoryBot.definition_file_paths = [
  Inferno::SpecSupport::FACTORY_PATH
]

RSpec::Matchers.define_negated_matcher :exclude, :include
require_relative 'support/matchers/message_matchers'

FHIR.logger = Inferno::Application['logger']

DatabaseCleaner[:sequel].strategy = :truncation
DatabaseCleaner[:sequel].db = Inferno::Application['db.connection']
