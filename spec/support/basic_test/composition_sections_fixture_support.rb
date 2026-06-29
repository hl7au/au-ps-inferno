# frozen_string_literal: true

require 'json'

require_relative 'composition_sections_check_support'

module CompositionSectionsFixtureSupport
  FIXTURE_BUNDLES_DIR = File.expand_path('../../fixtures/bundles', __dir__).freeze
  FIXTURE_METADATA_PATH = File.expand_path('../../fixtures/metadata.yaml', __dir__).freeze

  def msg(text)
    text.chomp
  end

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
end
