# frozen_string_literal: true

# Full Inferno application, database, and FactoryBot. Use for integration-style specs:
#   require_relative 'spec_helper_inferno'
#
# Default spec/spec_helper.rb avoids loading Inferno (avoids activesupport / concurrent-ruby
# version conflicts with inferno_core in some bundle resolutions).

require_relative 'spec_helper'

require 'database_cleaner/sequel'
require 'pry'
require 'pry-byebug'

require 'factory_bot'

RSpec.configure do |config|
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

FHIR.logger = Inferno::Application['logger']

DatabaseCleaner[:sequel].strategy = :truncation
DatabaseCleaner[:sequel].db = Inferno::Application['db.connection']
