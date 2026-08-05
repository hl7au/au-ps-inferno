# frozen_string_literal: true

require_relative 'composition_sections_fixture_support'
require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

RSpec.shared_context 'composition section negation check setup' do
  include_context 'when testing a runnable'
  include_context 'composition sections check setup'
  include CompositionSectionsFixtureSupport

  let(:test) do
    test_id = "#{suite_id}-nilknown_warning"
    test_class = Class.new(Inferno::Test) do
      include CompositionUtils
      include AUPSTestKit::SectionNamesMapping
      include AUPSTestKit::BasicTestCompositionSectionNegationModule

      id test_id

      run { warn_on_nilknown_empty_reason(%w[11450-4 48765-2 10160-0]) }
    end

    repo = Inferno::Repositories::Tests.new
    repo.insert(test_class) unless repo.exists?(test_id)
    test_class
  end
end
