# frozen_string_literal: true

require 'yaml'
require 'json'
require 'fhir_models'

require_relative '../fixtures/ms_checks_suite'
require_relative '../../lib/au_ps_inferno/utils/composition_utils'
require_relative '../../lib/au_ps_inferno/utils/metadata_manager'
require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

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

RSpec.describe MSCheckSuiteKit::MSCheckSuite do
  include_context 'when testing a runnable'
  include MsChecksSuiteSpecSupport

  let(:suite_id) { 'ms_check_suite' }
  let(:suite) { described_class }
  let(:test) { find_test(suite, 'mandatory_ms_elements_populated') }

  before do
    register_runnable_tree(described_class)
    configure_test_class(test)
  end

  describe 'mandatory_ms_elements_populated test' do
    it 'passes for a valid mandatory bundle fixture' do
      result = run(test, {}, scratch_with_bundle_fixture)
      messages = Inferno::Repositories::Messages.new.messages_for_result(result.id)

      puts messages.inspect

      expect(messages).not_to be_empty
      expect(result.result).to eq('pass'), result.result_message
    end
  end
end
