# frozen_string_literal: true

require 'json'

require_relative 'composition_sections_check_support'

module CompositionSectionsFixtureSupport
  FIXTURE_BUNDLES_DIR = File.expand_path('../../fixtures/bundles', __dir__).freeze
  FIXTURE_METADATA_DIR = File.expand_path('../../fixtures/metadata', __dir__).freeze
  FIXTURE_METADATA_PATH = File.expand_path('../../fixtures/metadata.yaml', __dir__).freeze
  BALLOT_METADATA_PATH = File.expand_path('../../../lib/au_ps_inferno/1.0.0-ballot/metadata.yaml', __dir__).freeze

  def load_fixture_bundle_hash(filename)
    fixture_path = File.join(FIXTURE_BUNDLES_DIR, filename)
    JSON.parse(File.read(fixture_path))
  end

  def load_fixture_bundle(filename)
    FHIR.from_contents(JSON.generate(load_fixture_bundle_hash(filename)))
  end

  def run_with_fixture_bundle(test, fixture_filename:)
    bundle = load_fixture_bundle(fixture_filename)
    result = run(test, {}, scratch_with(bundle))
    { result: result, messages: messages_for(result) }
  end

  def run_with_fixture_bundle_for(test_method:, fixture_filename:, metadata_fixture_filename: nil)
    test_class = find_test(test_method)
    resolved_metadata_path =
      if metadata_fixture_filename
        metadata_path_from_fixture_filename(metadata_fixture_filename)
      elsif respond_to?(:metadata_path)
        metadata_path
      end
    configure_test_class_with_metadata_path(test_class, resolved_metadata_path) if resolved_metadata_path
    run_with_fixture_bundle(test_class, fixture_filename: fixture_filename)
  end

  def metadata_fixture_path(metadata_fixture_filename)
    File.join(FIXTURE_METADATA_DIR, metadata_fixture_filename)
  end

  def metadata_path_from_fixture_filename(metadata_fixture_filename)
    candidate_path = metadata_fixture_path(metadata_fixture_filename)
    File.exist?(candidate_path) ? candidate_path : FIXTURE_METADATA_PATH
  end

  def configure_test_class_with_metadata_path(test_class, metadata_path)
    manager = AUPSTestKit::MetadataManager.new(metadata_path)
    test_class.class_eval do
      include CompositionUtils unless ancestors.include?(CompositionUtils)
      unless ancestors.include?(AUPSTestKit::BasicTestCompositionSectionReadModule)
        include AUPSTestKit::BasicTestCompositionSectionReadModule
      end
      define_method(:metadata_manager) { manager }
    end
  end

  def configure_test_class_with_ballot_metadata(test_class)
    configure_test_class_with_metadata_path(test_class, BALLOT_METADATA_PATH)
  end
end
