# frozen_string_literal: true

require 'fhir_models'
require 'json'
require 'webmock/rspec'

require_relative '../../../lib/au_ps_inferno/suite/bundle_acquisition/suite_bundle_acquisition_from_resource'
require_relative '../../../lib/au_ps_inferno/suite/bundle_acquisition/suite_bundle_acquisition_from_url'
require_relative '../../../lib/au_ps_inferno/suite/bundle_acquisition/suite_bundle_acquisition_from_bundle_id'
require_relative '../../../lib/au_ps_inferno/suite/bundle_acquisition/suite_bundle_acquisition_from_patient_id'
require_relative '../../../lib/au_ps_inferno/suite/bundle_acquisition/suite_bundle_acquisition_from_identifier'

require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

RSpec.describe 'Bundle acquisition tests (five methods, one shared input set)' do
  include_context 'when testing a runnable'

  let(:suite_id) { 'bundle_acquisition_tests_test_suite' }
  let(:server_url) { 'https://example.com/fhir' }

  before do
    suite_stub = Class.new(Inferno::TestSuite) { id 'bundle_acquisition_tests_test_suite' }
    repo = Inferno::Repositories::TestSuites.new
    repo.insert(suite_stub) unless repo.exists?('bundle_acquisition_tests_test_suite')
  end

  def create_test(test_id, superclass)
    klass = Class.new(superclass) { id test_id }
    repo = Inferno::Repositories::Tests.new
    repo.insert(klass) unless repo.exists?(test_id)
    klass
  end

  def bundle_json
    FHIR::Bundle.new(resourceType: 'Bundle', type: 'document', timestamp: '2025-01-01T00:00:00Z').to_json
  end

  def info_messages(result)
    Inferno::Repositories::Messages.new.messages_for_result(result.id).select { |m| m.type == 'info' }
  end

  describe AUPSTestKit::AUPSSuiteBundleAcquisitionFromResource do
    it 'omits when Bundle Resource is not the selected retrieval method' do
      test = create_test('bundle_acquisition_from_resource_wrong_method_test', described_class)
      result = run(test, { bundle_retrieve_method: 'bundle_url', bundle_resource: bundle_json })

      expect(result.result).to eq('omit')
    end

    it 'omits when no Bundle text is provided' do
      test = create_test('bundle_acquisition_from_resource_blank_test', described_class)
      result = run(test, { bundle_retrieve_method: 'bundle_resource' })

      expect(result.result).to eq('omit')
    end

    it 'fails when the provided text is not parseable' do
      test = create_test('bundle_acquisition_from_resource_garbage_test', described_class)
      result = run(test, { bundle_retrieve_method: 'bundle_resource', bundle_resource: 'not fhir json' })

      expect(result.result).to eq('fail')
    end

    it 'fails when the provided resource is not a Bundle' do
      test = create_test('bundle_acquisition_from_resource_patient_test', described_class)
      result = run(test, { bundle_retrieve_method: 'bundle_resource',
                           bundle_resource: FHIR::Patient.new(id: 'p1').to_json })

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/expected a Bundle/)
    end

    it 'stores the parsed Bundle and the validate_against choice in scratch' do
      test = create_test('bundle_acquisition_from_resource_store_test', described_class)
      scratch = {}
      result = run(test, { bundle_retrieve_method: 'bundle_resource', bundle_resource: bundle_json,
                           validate_against: ['au_ps_bundle'] }, scratch)

      expect(result.result).to eq('pass')
      expect(scratch[:bundle_ips_resource]).to be_a(FHIR::Bundle)
      expect(scratch[:validate_against]).to eq(['au_ps_bundle'])
      expect(info_messages(result).map(&:message)).to include(a_string_matching(/pasted FHIR resource/))
    end
  end

  describe AUPSTestKit::AUPSSuiteBundleAcquisitionFromUrl do
    let(:bundle_url) { 'https://example.com/fhir/Bundle/doc-1' }

    it 'omits when Bundle URL is not the selected retrieval method' do
      test = create_test('bundle_acquisition_from_url_wrong_method_test', described_class)
      result = run(test, { bundle_retrieve_method: 'bundle_resource', bundle_url: bundle_url })

      expect(result.result).to eq('omit')
    end

    it 'fetches, records the request, and stores the Bundle' do
      stub_request(:get, bundle_url)
        .to_return(status: 200, body: bundle_json, headers: { 'Content-Type' => 'application/fhir+json' })

      test = create_test('bundle_acquisition_from_url_fetch_test', described_class)
      scratch = {}
      result = run(test, { bundle_retrieve_method: 'bundle_url', bundle_url: bundle_url }, scratch)

      expect(result.result).to eq('pass')
      expect(scratch[:bundle_ips_resource]).to be_a(FHIR::Bundle)
      requests = Inferno::Repositories::Requests.new.requests_for_result(result.id)
      expect(requests.length).to eq(1)
      expect(requests.first.url).to eq(bundle_url)
    end

    it 'sends the configured extra header' do
      stub_request(:get, bundle_url)
        .with(headers: { 'X-Api-Key' => 'secret' })
        .to_return(status: 200, body: bundle_json, headers: { 'Content-Type' => 'application/fhir+json' })

      test = create_test('bundle_acquisition_from_url_header_test', described_class)
      result = run(test, { bundle_retrieve_method: 'bundle_url', bundle_url: bundle_url,
                           bundle_url_header_name: 'X-Api-Key', bundle_url_header_value: 'secret' })

      expect(result.result).to eq('pass')
    end

    it 'fails cleanly when the URL does not return a Bundle' do
      stub_request(:get, bundle_url)
        .to_return(status: 200, body: FHIR::Patient.new(id: 'p1').to_json,
                   headers: { 'Content-Type' => 'application/fhir+json' })

      test = create_test('bundle_acquisition_from_url_not_bundle_test', described_class)
      result = run(test, { bundle_retrieve_method: 'bundle_url', bundle_url: bundle_url })

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/expected a Bundle/)
    end
  end

  describe AUPSTestKit::AUPSSuiteBundleAcquisitionFromBundleId do
    it 'omits when FHIR Server is not the selected retrieval method' do
      test = create_test('bundle_acquisition_from_bundle_id_wrong_method_test', described_class)
      result = run(test, { bundle_retrieve_method: 'bundle_url', url: server_url, bundle_id: 'bundle1' })

      expect(result.result).to eq('omit')
    end

    it 'omits in favor of $summary when a Patient ID is also given' do
      test = create_test('bundle_acquisition_from_bundle_id_prefers_summary_test', described_class)
      result = run(test, { bundle_retrieve_method: 'fhir_server', url: server_url, bundle_id: 'bundle1',
                           patient_id: 'pat1' })

      expect(result.result).to eq('omit')
      expect(WebMock).not_to have_requested(:get, "#{server_url}/Bundle/bundle1")
    end

    it 'omits in favor of $summary when a Patient identifier is also given' do
      test = create_test('bundle_acquisition_from_bundle_id_prefers_identifier_test', described_class)
      result = run(test, { bundle_retrieve_method: 'fhir_server', url: server_url, bundle_id: 'bundle1',
                           identifier: 'ident1' })

      expect(result.result).to eq('omit')
    end

    it 'retrieves the Bundle by ID from the FHIR server' do
      stub_request(:get, "#{server_url}/Bundle/bundle1")
        .to_return(status: 200, body: bundle_json, headers: { 'Content-Type' => 'application/fhir+json' })

      test = create_test('bundle_acquisition_from_bundle_id_fetch_test', described_class)
      scratch = {}
      result = run(test, { bundle_retrieve_method: 'fhir_server', url: server_url, bundle_id: 'bundle1' }, scratch)

      expect(result.result).to eq('pass')
      expect(scratch[:bundle_ips_resource]).to be_a(FHIR::Bundle)
    end
  end

  describe AUPSTestKit::AUPSSuiteBundleAcquisitionFromPatientId do
    it 'omits when a Patient identifier is also given (identifier takes precedence)' do
      test = create_test('bundle_acquisition_from_patient_id_prefers_identifier_test', described_class)
      result = run(test, { bundle_retrieve_method: 'fhir_server', url: server_url, patient_id: 'pat1',
                           identifier: 'ident1' })

      expect(result.result).to eq('omit')
      expect(WebMock).not_to have_requested(:get, "#{server_url}/Patient/pat1/$summary")
    end

    it 'calls $summary and stores the Bundle' do
      stub_request(:get, "#{server_url}/Patient/pat1/$summary")
        .with(query: { 'profile' => 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle' })
        .to_return(status: 200, body: bundle_json, headers: { 'Content-Type' => 'application/fhir+json' })

      test = create_test('bundle_acquisition_from_patient_id_fetch_test', described_class)
      scratch = {}
      result = run(test, { bundle_retrieve_method: 'fhir_server', url: server_url, patient_id: 'pat1' }, scratch)

      expect(result.result).to eq('pass')
      expect(scratch[:bundle_ips_resource]).to be_a(FHIR::Bundle)
    end
  end

  describe AUPSTestKit::AUPSSuiteBundleAcquisitionFromIdentifier do
    it 'omits when no Patient identifier is given' do
      test = create_test('bundle_acquisition_from_identifier_blank_test', described_class)
      result = run(test, { bundle_retrieve_method: 'fhir_server', url: server_url, patient_id: 'pat1' })

      expect(result.result).to eq('omit')
    end

    it 'calls $summary by identifier and stores the Bundle' do
      stub_request(:get, "#{server_url}/Patient/$summary")
        .with(query: { 'identifier' => 'ident1',
                       'profile' => 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle' })
        .to_return(status: 200, body: bundle_json, headers: { 'Content-Type' => 'application/fhir+json' })

      test = create_test('bundle_acquisition_from_identifier_fetch_test', described_class)
      scratch = {}
      result = run(test, { bundle_retrieve_method: 'fhir_server', url: server_url, identifier: 'ident1' }, scratch)

      expect(result.result).to eq('pass')
      expect(scratch[:bundle_ips_resource]).to be_a(FHIR::Bundle)
    end

    it 'notes that identifier search took precedence when a Patient ID is also given' do
      stub_request(:get, "#{server_url}/Patient/$summary")
        .with(query: { 'identifier' => 'ident1',
                       'profile' => 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle' })
        .to_return(status: 200, body: bundle_json, headers: { 'Content-Type' => 'application/fhir+json' })

      test = create_test('bundle_acquisition_from_identifier_precedence_test', described_class)
      result = run(test, { bundle_retrieve_method: 'fhir_server', url: server_url, identifier: 'ident1',
                           patient_id: 'pat1' })

      expect(result.result).to eq('pass')
      expect(info_messages(result).map(&:message)).to include(a_string_matching(/takes precedence/))
    end
  end
end
