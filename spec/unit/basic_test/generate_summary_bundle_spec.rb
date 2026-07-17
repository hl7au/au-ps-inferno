# frozen_string_literal: true

require 'fhir_models'
require 'json'
require 'webmock/rspec'

require_relative '../../../lib/au_ps_inferno/utils/generate_summary_bundle_test_class'
require_relative '../../../lib/au_ps_inferno/utils/metadata_manager'

require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

GENERATE_SUMMARY_FIXTURE_METADATA_PATH = File.expand_path('../../fixtures/metadata.yaml', __dir__).freeze

RSpec.describe AUPSTestKit::GenerateSummaryBundleTestClass do
  include_context 'when testing a runnable'

  let(:suite_id) { 'generate_summary_bundle_test_suite' }
  let(:server_url) { 'https://example.com/fhir' }

  before do
    suite_stub = Class.new(Inferno::TestSuite) { id 'generate_summary_bundle_test_suite' }
    repo = Inferno::Repositories::TestSuites.new
    repo.insert(suite_stub) unless repo.exists?('generate_summary_bundle_test_suite')
  end

  def create_test(test_id)
    klass = Class.new(described_class) do
      id test_id
      define_method(:metadata_manager) do
        @metadata_manager ||= AUPSTestKit::MetadataManager.new(GENERATE_SUMMARY_FIXTURE_METADATA_PATH)
      end
    end
    repo = Inferno::Repositories::Tests.new
    repo.insert(klass) unless repo.exists?(test_id)
    klass
  end

  def bundle_json
    FHIR::Bundle.new(resourceType: 'Bundle', type: 'document', timestamp: '2025-01-01T00:00:00Z').to_json
  end

  it 'attempts $summary even when the CapabilityStatement does not declare it (issue #98)' do
    stub_request(:get, "#{server_url}/Patient/pat1/$summary")
      .with(query: { 'profile' => 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle' })
      .to_return(status: 200, body: bundle_json, headers: { 'Content-Type' => 'application/fhir+json' })

    test = create_test('suite_generate_au_ps_using_ips_summary_validation_tests_no_cs_gate_test')
    scratch = { summary_op_defined: false }
    result = run(test, {
                   url: server_url,
                   patient_id: 'pat1',
                   profile: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle'
                 }, scratch)

    expect(result.result).to eq('pass')
    expect(scratch[:bundle_ips_resource_summary]).to be_a(FHIR::Bundle)
  end

  it 'omits when no server URL or patient details are provided' do
    test = create_test('suite_generate_au_ps_using_ips_summary_validation_tests_omit_test')
    result = run(test, {})

    expect(result.result).to eq('omit')
  end
end
