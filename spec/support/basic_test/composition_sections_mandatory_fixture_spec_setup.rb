# frozen_string_literal: true

require 'fhir_models'

require_relative 'composition_sections_fixture_support'
require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

# MetadataManager that serves in-memory metadata (same shape as YAML) without stubbing :metadata.
class CompositionSectionsHashMetadataManager < AUPSTestKit::MetadataManager
  def initialize(metadata_hash)
    @metadata_hash = metadata_hash
    super(nil)
  end

  def metadata
    @metadata_hash
  end
end

module CompositionSectionsMandatoryFixtureSpecSetup
  def configure_mandatory_fixture_test(test_class, metadata_hash)
    manager = CompositionSectionsHashMetadataManager.new(metadata_hash)
    test_class.class_eval do
      include CompositionUtils unless ancestors.include?(CompositionUtils)
      unless ancestors.include?(AUPSTestKit::BasicTestCompositionSectionReadModule)
        include AUPSTestKit::BasicTestCompositionSectionReadModule
      end
      define_method(:metadata_manager) { manager }
    end
  end
end

RSpec.shared_context 'mandatory composition sections fixture' do
  include CompositionSectionsMandatoryFixtureSpecSetup

  include_context 'when testing a runnable'
  include_context 'composition sections check setup'
  include CompositionSectionsFixtureSupport

  before { configure_mandatory_fixture_test(test, metadata) }
end

RSpec.shared_context 'mandatory composition sections fixture by metadata path' do
  include_context 'when testing a runnable'
  include_context 'composition sections check setup'
  include CompositionSectionsFixtureSupport

  let(:test_method) { :test_composition_mandatory_sections }
  let(:test) { find_test(test_method) }
  let(:metadata_fixture_filename) { 'metadata.yaml' }
  let(:metadata_path) { metadata_path_from_fixture_filename(metadata_fixture_filename) }

  before { configure_test_class_with_metadata_path(test, metadata_path) }
end

RSpec.shared_context 'recommended composition sections fixture by metadata path' do
  include_context 'when testing a runnable'
  include_context 'composition sections check setup'
  include CompositionSectionsFixtureSupport

  let(:test_method) { :test_composition_recommended_sections }
  let(:test) { find_test(test_method) }
  let(:metadata_fixture_filename) { 'metadata.yaml' }
  let(:metadata_path) { metadata_path_from_fixture_filename(metadata_fixture_filename) }

  before { configure_test_class_with_metadata_path(test, metadata_path) }
end

RSpec.shared_context 'optional composition sections fixture by metadata path' do
  include_context 'when testing a runnable'
  include_context 'composition sections check setup'
  include CompositionSectionsFixtureSupport

  let(:test_method) { :test_composition_optional_sections }
  let(:test) { find_test(test_method) }
  let(:metadata_fixture_filename) { 'metadata.yaml' }
  let(:metadata_path) { metadata_path_from_fixture_filename(metadata_fixture_filename) }

  before { configure_test_class_with_metadata_path(test, metadata_path) }
end
