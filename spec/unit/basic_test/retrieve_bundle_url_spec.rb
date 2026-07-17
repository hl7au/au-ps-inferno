# frozen_string_literal: true

require 'fhir_models'
require 'json'
require 'webmock/rspec'

require_relative '../../../lib/au_ps_inferno/utils/retrieve_bundle_test_class'
require_relative '../../../lib/au_ps_inferno/utils/metadata_manager'

require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

RETRIEVE_URL_FIXTURE_METADATA_PATH = File.expand_path('../../fixtures/metadata.yaml', __dir__).freeze

RSpec.describe AUPSTestKit::RetrieveBundleTestClass do
  include_context 'when testing a runnable'

  let(:suite_id) { 'retrieve_bundle_url_test_suite' }
  let(:bundle_url) { 'https://example.com/fhir/Bundle/doc-1' }

  before do
    suite_stub = Class.new(Inferno::TestSuite) { id 'retrieve_bundle_url_test_suite' }
    repo = Inferno::Repositories::TestSuites.new
    repo.insert(suite_stub) unless repo.exists?('retrieve_bundle_url_test_suite')
  end

  def create_test(test_id)
    klass = Class.new(described_class) do
      id test_id
      define_method(:metadata_manager) do
        @metadata_manager ||= AUPSTestKit::MetadataManager.new(RETRIEVE_URL_FIXTURE_METADATA_PATH)
      end
    end
    repo = Inferno::Repositories::Tests.new
    repo.insert(klass) unless repo.exists?(test_id)
    klass
  end

  def bundle_json
    FHIR::Bundle.new(resourceType: 'Bundle', type: 'document', timestamp: '2025-01-01T00:00:00Z').to_json
  end

  it 'records the direct-URL retrieval as an Inferno request and saves the Bundle (issue #98)' do
    stub_request(:get, bundle_url)
      .to_return(status: 200, body: bundle_json, headers: { 'Content-Type' => 'application/fhir+json' })

    test = create_test('suite_retrieve_au_ps_bundle_validation_tests_url_fetch_test')
    scratch = {}
    result = run(test, { bundle_url: bundle_url }, scratch)

    expect(result.result).to eq('pass')
    expect(scratch[:bundle_ips_resource_retrieve]).to be_a(FHIR::Bundle)
    requests = Inferno::Repositories::Requests.new.requests_for_result(result.id)
    expect(requests.length).to eq(1)
    expect(requests.first.url).to eq(bundle_url)
  end

  it 'sends the configured extra header with the direct-URL retrieval' do
    stub_request(:get, bundle_url)
      .with(headers: { 'X-Api-Key' => 'secret' })
      .to_return(status: 200, body: bundle_json, headers: { 'Content-Type' => 'application/fhir+json' })

    test = create_test('suite_retrieve_au_ps_bundle_validation_tests_url_header_test')
    result = run(test, { bundle_url: bundle_url, header_name: 'X-Api-Key', header_value: 'secret' })

    expect(result.result).to eq('pass')
  end

  it 'fails cleanly when the URL does not return a Bundle' do
    stub_request(:get, bundle_url)
      .to_return(status: 200, body: FHIR::Patient.new(id: 'p1').to_json,
                 headers: { 'Content-Type' => 'application/fhir+json' })

    test = create_test('suite_retrieve_au_ps_bundle_validation_tests_url_not_bundle_test')
    result = run(test, { bundle_url: bundle_url })

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/expected a Bundle/)
  end
end
