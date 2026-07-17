# frozen_string_literal: true

require 'fhir_models'
require 'json'

require_relative '../../../lib/au_ps_inferno/utils/provided_bundle_test_class'
require_relative '../../../lib/au_ps_inferno/utils/bundle_is_valid_class'
require_relative '../../../lib/au_ps_inferno/utils/metadata_manager'

require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

BUNDLE_ACQUISITION_FIXTURE_METADATA_PATH = File.expand_path('../../fixtures/metadata.yaml', __dir__).freeze

RSpec.describe 'Bundle acquisition split from validation (issue #98)' do
  include_context 'when testing a runnable'

  let(:suite_id) { 'bundle_acquisition_split_test_suite' }

  before do
    suite_stub = Class.new(Inferno::TestSuite) { id 'bundle_acquisition_split_test_suite' }
    repo = Inferno::Repositories::TestSuites.new
    repo.insert(suite_stub) unless repo.exists?('bundle_acquisition_split_test_suite')
  end

  def bundle_json
    FHIR::Bundle.new(
      resourceType: 'Bundle',
      type: 'document',
      timestamp: '2025-01-01T00:00:00Z'
    ).to_json
  end

  def create_test(test_id, superclass)
    klass = Class.new(superclass) do
      id test_id
      define_method(:metadata_manager) do
        @metadata_manager ||= AUPSTestKit::MetadataManager.new(BUNDLE_ACQUISITION_FIXTURE_METADATA_PATH)
      end
    end
    repo = Inferno::Repositories::Tests.new
    repo.insert(klass) unless repo.exists?(test_id)
    klass
  end

  describe AUPSTestKit::ProvidedBundleTestClass do
    it 'omits when no Bundle text is provided' do
      test = create_test('suite_au_ps_bundle_instance_provide_omit_test', described_class)
      result = run(test, {})

      expect(result.result).to eq('omit')
    end

    it 'fails when the provided text is not parseable' do
      test = create_test('suite_au_ps_bundle_instance_provide_garbage_test', described_class)
      result = run(test, { bundle_resource: 'not fhir json' })

      expect(result.result).to eq('fail')
    end

    it 'fails when the provided resource is not a Bundle' do
      test = create_test('suite_au_ps_bundle_instance_provide_patient_test', described_class)
      result = run(test, { bundle_resource: FHIR::Patient.new(id: 'p1').to_json })

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/expected a Bundle/)
    end

    it 'stores the parsed Bundle under its own group scratch key' do
      test = create_test('suite_au_ps_bundle_instance_provide_store_test', described_class)
      scratch = {}
      result = run(test, { bundle_resource: bundle_json }, scratch)

      expect(result.result).to eq('pass')
      expect(scratch[:bundle_ips_resource_instance]).to be_a(FHIR::Bundle)
    end
  end

  describe AUPSTestKit::BundleIsValidClass do
    it 'omits when its group has no Bundle in scratch' do
      test = create_test('suite_retrieve_au_ps_bundle_validation_tests_valid_omit_test', described_class)
      result = run(test, { validate_against: ['au_ps_bundle'] }, {})

      expect(result.result).to eq('omit')
      expect(result.result_message).to match(/No AU PS Bundle was loaded by this test group/)
    end
  end
end
