# frozen_string_literal: true

require 'fhir_models'
require 'json'

require_relative '../../../lib/au_ps_inferno/utils/provided_bundle_test_class'
require_relative '../../../lib/au_ps_inferno/utils/bundle_is_valid_class'
require_relative '../../../lib/au_ps_inferno/utils/metadata_manager'
require_relative '../../../lib/au_ps_inferno/suite/au_ps_bundle_instance/suite_au_ps_bundle_instance_bundle_retrieve'
require_relative '../../../lib/au_ps_inferno/suite/au_ps_bundle_instance/suite_au_ps_bundle_instance_bundle_summary'

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

  def declare_optional_inputs(klass, names)
    names.each { |name| klass.input name, optional: true }
  end

  def create_test(test_id, superclass, extra_inputs: [], fhir_client_url_input: nil)
    klass = Class.new(superclass) do
      id test_id
      fhir_client { url fhir_client_url_input } if fhir_client_url_input
      define_method(:metadata_manager) do
        @metadata_manager ||= AUPSTestKit::MetadataManager.new(BUNDLE_ACQUISITION_FIXTURE_METADATA_PATH)
      end
    end
    declare_optional_inputs(klass, extra_inputs)
    Inferno::Repositories::Tests.new.tap { |repo| repo.insert(klass) unless repo.exists?(test_id) }
    klass
  end

  describe AUPSTestKit::ProvidedBundleTestClass do
    let(:extra_inputs) { %i[retrieval_method bundle_resource] }

    it 'omits when no Bundle text is provided' do
      test = create_test('suite_au_ps_bundle_instance_provide_omit_test', described_class,
                         extra_inputs: extra_inputs)
      result = run(test, { retrieval_method: 'json_file' })

      expect(result.result).to eq('omit')
    end

    it "omits when a retrieval method other than 'JSON file' is selected (issue #98)" do
      test = create_test('suite_au_ps_bundle_instance_provide_not_selected_test', described_class,
                         extra_inputs: extra_inputs)
      result = run(test, { retrieval_method: 'url', bundle_resource: bundle_json })

      expect(result.result).to eq('omit')
    end

    it 'fails when the provided text is not parseable' do
      test = create_test('suite_au_ps_bundle_instance_provide_garbage_test', described_class,
                         extra_inputs: extra_inputs)
      result = run(test, { retrieval_method: 'json_file', bundle_resource: 'not fhir json' })

      expect(result.result).to eq('fail')
    end

    it 'fails when the provided resource is not a Bundle' do
      test = create_test('suite_au_ps_bundle_instance_provide_patient_test', described_class,
                         extra_inputs: extra_inputs)
      result = run(test, { retrieval_method: 'json_file', bundle_resource: FHIR::Patient.new(id: 'p1').to_json })

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/expected a Bundle/)
    end

    it 'stores the parsed Bundle under its own group scratch key' do
      test = create_test('suite_au_ps_bundle_instance_provide_store_test', described_class,
                         extra_inputs: extra_inputs)
      scratch = {}
      result = run(test, { retrieval_method: 'json_file', bundle_resource: bundle_json }, scratch)

      expect(result.result).to eq('pass')
      expect(scratch[:bundle_ips_resource_instance]).to be_a(FHIR::Bundle)
    end
  end

  describe AUPSTestKit::BundleIsValidClass do
    it 'omits when its group has no Bundle in scratch' do
      test = create_test('suite_retrieve_au_ps_bundle_validation_tests_valid_omit_test', described_class)
      result = run(test, {
                     retrieval_method: 'json_file', validate_against: ['au_ps_bundle'],
                     auth_needed_retrieve: 'false', auth_needed_sum: 'false'
                   }, {})

      expect(result.result).to eq('omit')
      expect(result.result_message).to match(/No AU PS Bundle was loaded by this test group/)
    end
  end

  describe AUPSTestKit::AUPSSuiteAuPsBundleInstanceBundleAcquisitionRetrieveAuPsBundle do
    let(:extra_inputs) do
      %i[retrieval_method bundle_url url_retrieve bundle_id header_name_retrieve header_value_retrieve]
    end
    let(:bundle_url) { 'https://example.com/fhir/Bundle/doc-1' }

    it "omits when a retrieval method other than 'URL to FHIR Bundle' is selected (issue #98)" do
      test = create_test('suite_au_ps_bundle_instance_retrieve_not_selected_test', described_class,
                         extra_inputs: extra_inputs)
      result = run(test, { retrieval_method: 'json_file', bundle_url: bundle_url })

      expect(result.result).to eq('omit')
    end

    it 'retrieves the Bundle from a direct URL and stores it under the group scratch key' do
      stub_request(:get, bundle_url)
        .to_return(status: 200, body: bundle_json, headers: { 'Content-Type' => 'application/fhir+json' })

      test = create_test('suite_au_ps_bundle_instance_retrieve_store_test', described_class,
                         extra_inputs: extra_inputs)
      scratch = {}
      result = run(test, { retrieval_method: 'url', bundle_url: bundle_url }, scratch)

      expect(result.result).to eq('pass')
      expect(scratch[:bundle_ips_resource_instance]).to be_a(FHIR::Bundle)
    end
  end

  describe AUPSTestKit::AUPSSuiteAuPsBundleInstanceBundleAcquisitionGenerateAuPsBundleViaSummary do
    let(:extra_inputs) { %i[retrieval_method url_sum patient_id identifier profile] }
    let(:server_url) { 'https://example.com/fhir' }

    it "omits when a retrieval method other than '$summary Operation' is selected (issue #98)" do
      test = create_test('suite_au_ps_bundle_instance_summary_not_selected_test', described_class,
                         extra_inputs: extra_inputs)
      result = run(test, { retrieval_method: 'url', url_sum: server_url, patient_id: 'pat1' })

      expect(result.result).to eq('omit')
    end

    it 'generates the Bundle via $summary and stores it under the group scratch key' do
      stub_request(:get, "#{server_url}/Patient/pat1/$summary")
        .to_return(status: 200, body: bundle_json, headers: { 'Content-Type' => 'application/fhir+json' })

      test = create_test('suite_au_ps_bundle_instance_summary_store_test', described_class,
                         extra_inputs: extra_inputs, fhir_client_url_input: :url_sum)
      scratch = {}
      result = run(test, { retrieval_method: 'summary_op', url_sum: server_url, patient_id: 'pat1' }, scratch)

      expect(result.result).to eq('pass')
      expect(scratch[:bundle_ips_resource_instance]).to be_a(FHIR::Bundle)
    end
  end

  describe 'switching retrieval method between runs (issue #98)' do
    it 'overwrites, rather than accumulates in, the group scratch key' do
      provide_test = create_test('suite_au_ps_bundle_instance_switch_provide_test',
                                 AUPSTestKit::ProvidedBundleTestClass,
                                 extra_inputs: %i[retrieval_method bundle_resource])
      scratch = {}
      first_result = run(provide_test, { retrieval_method: 'json_file', bundle_resource: bundle_json }, scratch)
      expect(first_result.result).to eq('pass')
      first_bundle = scratch[:bundle_ips_resource_instance]
      expect(first_bundle).to be_a(FHIR::Bundle)

      bundle_url = 'https://example.com/fhir/Bundle/doc-2'
      stub_request(:get, bundle_url)
        .to_return(status: 200, body: bundle_json, headers: { 'Content-Type' => 'application/fhir+json' })

      retrieve_test = create_test(
        'suite_au_ps_bundle_instance_switch_retrieve_test',
        AUPSTestKit::AUPSSuiteAuPsBundleInstanceBundleAcquisitionRetrieveAuPsBundle,
        extra_inputs: %i[retrieval_method bundle_url url_retrieve bundle_id header_name_retrieve
                         header_value_retrieve]
      )
      second_result = run(retrieve_test, { retrieval_method: 'url', bundle_url: bundle_url }, scratch)

      expect(second_result.result).to eq('pass')
      expect(scratch[:bundle_ips_resource_instance]).to be_a(FHIR::Bundle)
      expect(scratch[:bundle_ips_resource_instance]).not_to equal(first_bundle)
    end
  end
end
