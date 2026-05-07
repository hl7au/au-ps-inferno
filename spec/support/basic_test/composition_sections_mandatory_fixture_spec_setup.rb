# frozen_string_literal: true

require 'fhir_models'

require_relative 'composition_sections_fixture_support'
require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

RSpec.shared_context 'composition sections by metadata path base' do
  include_context 'when testing a runnable'
  include_context 'composition sections check setup'
  include CompositionSectionsFixtureSupport

  let(:test) { find_test(test_method) }

  before { configure_test_class_with_metadata_path(test, CompositionSectionsFixtureSupport::FIXTURE_METADATA_PATH) }
end

RSpec.shared_context 'mandatory composition sections fixture by metadata path' do
  include_context 'composition sections by metadata path base'
  let(:test_method) { :test_composition_mandatory_sections }
end

RSpec.shared_context 'recommended composition sections fixture by metadata path' do
  include_context 'composition sections by metadata path base'
  let(:test_method) { :test_composition_recommended_sections }
end

RSpec.shared_context 'optional composition sections fixture by metadata path' do
  include_context 'composition sections by metadata path base'
  let(:test_method) { :test_composition_optional_sections }
end
