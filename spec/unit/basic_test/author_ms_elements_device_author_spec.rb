# frozen_string_literal: true

require 'fhir_models'
require 'json'

require_relative '../../../lib/au_ps_inferno/utils/basic_test_class'
require_relative '../../../lib/au_ps_inferno/utils/metadata_manager'

require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

RSpec.describe 'Author Must Support element tests omit when author is Device' do
  DEVICE_AUTHOR_FIXTURE_METADATA_PATH = File.expand_path('../../fixtures/metadata.yaml', __dir__).freeze

  include_context 'when testing a runnable'

  let(:suite_id) { 'author_device_ms_test_suite' }
  let(:device_full_url) { 'urn:uuid:device-1' }

  let(:bundle) do
    FHIR::Bundle.new(
      resourceType: 'Bundle',
      identifier: { system: 'urn:ietf:rfc:3986', value: 'urn:uuid:test-device-author-bundle' },
      type: 'document',
      timestamp: '2025-01-01T00:00:00Z',
      entry: [
        FHIR::Bundle::Entry.new(
          fullUrl: 'urn:uuid:composition-1',
          resource: FHIR::Composition.new(
            resourceType: 'Composition',
            id: 'composition-1',
            status: 'final',
            type: { coding: [{ system: 'http://loinc.org', code: '60591-5' }] },
            subject: { reference: 'urn:uuid:patient-1' },
            author: [{ reference: device_full_url }],
            title: 'Test Australian Patient Summary',
            custodian: { reference: 'urn:uuid:org-1' }
          )
        ),
        FHIR::Bundle::Entry.new(
          fullUrl: 'urn:uuid:patient-1',
          resource: FHIR::Patient.new(resourceType: 'Patient', id: 'patient-1')
        ),
        FHIR::Bundle::Entry.new(
          fullUrl: device_full_url,
          resource: FHIR::Device.new(resourceType: 'Device', id: 'device-1')
        )
      ]
    )
  end

  let(:bundle_entities) do
    bundle.entry.map do |entry|
      {
        full_url: entry.fullUrl,
        resource_type: entry.resource.resourceType,
        resource: entry.resource
      }
    end
  end

  let(:scratch) { { bundle_ips_resource: bundle, bundle_entities: bundle_entities } }

  before do
    suite_stub = Class.new(Inferno::TestSuite) { id 'author_device_ms_test_suite' }
    repo = Inferno::Repositories::TestSuites.new
    repo.insert(suite_stub) unless repo.exists?(suite_id)
  end

  def create_author_ms_test(test_id, method_name)
    metadata_path = DEVICE_AUTHOR_FIXTURE_METADATA_PATH
    klass = Class.new(AUPSTestKit::BasicTest) do
      id test_id
      run { send(method_name, 'author') }
      define_method(:metadata_manager) do
        @metadata_manager ||= AUPSTestKit::MetadataManager.new(metadata_path)
      end
    end
    repo = Inferno::Repositories::Tests.new
    repo.insert(klass) unless repo.exists?(test_id)
    klass
  end

  describe 'ms_elements_populated_message (test 1.9.02)' do
    it 'omits when author resolves to a Device resource' do
      test = create_author_ms_test('author_device_ms_elements_test', :ms_elements_populated_message)
      result = run(test, {}, scratch)

      expect(result.result).to eq('omit')
    end
  end

  describe 'ms_sub_elements_populated_message (test 1.9.03)' do
    it 'omits when author resolves to a Device resource' do
      test = create_author_ms_test('author_device_ms_sub_elements_test', :ms_sub_elements_populated_message)
      result = run(test, {}, scratch)

      expect(result.result).to eq('omit')
    end
  end
end
