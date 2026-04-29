# frozen_string_literal: true

require_relative '../../lib/au_ps_inferno/utils/composition_utils'
require_relative '../../lib/au_ps_inferno/utils/metadata_manager'

module MsChecksSuiteSpecSupport
  BUNDLE_FIXTURE_PATH = 'spec/fixtures/resources/bundle_mandatory_ok.json'
  METADATA_FIXTURE_PATH = 'spec/fixtures/metadata.yaml'

  def register_runnable_tree(runnable)
    repo_for(runnable)&.then { |repo| repo.insert(runnable) unless repo.exists?(runnable.id) }
    return unless runnable.respond_to?(:children)

    runnable.children.each { |child| register_runnable_tree(child) }
  end

  def repo_for(runnable)
    return Inferno::Repositories::TestSuites.new if runnable < Inferno::Entities::TestSuite
    return Inferno::Repositories::TestGroups.new if runnable < Inferno::Entities::TestGroup
    return Inferno::Repositories::Tests.new if runnable < Inferno::Entities::Test

    nil
  end

  def configure_test_class(test_class)
    test_class.class_eval do
      include CompositionUtils unless ancestors.include?(CompositionUtils)
      unless ancestors.include?(AUPSTestKit::BasicTestCompositionSectionReadModule)
        include AUPSTestKit::BasicTestCompositionSectionReadModule
      end
      define_method(:metadata_manager) { @metadata_manager ||= AUPSTestKit::MetadataManager.new(METADATA_FIXTURE_PATH) }
    end
  end

  def scratch_with_bundle_fixture
    bundle_json = File.read(BUNDLE_FIXTURE_PATH)
    bundle = FHIR::Bundle.new(JSON.parse(bundle_json))
    { bundle_ips_resource: bundle }
  end
end
