# frozen_string_literal: true

require 'fhir_models'
require 'json'

require_relative '../../../lib/au_ps_inferno/utils/basic_test_class'
require_relative '../../../lib/au_ps_inferno/utils/metadata_manager'

require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

BUNDLE_SCRATCH_FIXTURE_METADATA_PATH = File.expand_path('../../fixtures/metadata.yaml', __dir__).freeze

RSpec.describe 'Bundle scratch isolation between top-level groups (issue #98)' do
  include_context 'when testing a runnable'

  let(:suite_id) { 'bundle_scratch_isolation_test_suite' }
  let(:patient_full_url) { 'urn:uuid:patient-1' }

  before do
    suite_stub = Class.new(Inferno::TestSuite) { id 'bundle_scratch_isolation_test_suite' }
    repo = Inferno::Repositories::TestSuites.new
    repo.insert(suite_stub) unless repo.exists?('bundle_scratch_isolation_test_suite')
  end

  def build_bundle
    FHIR::Bundle.new(
      resourceType: 'Bundle',
      identifier: { system: 'urn:ietf:rfc:3986', value: 'urn:uuid:test-scratch-isolation-bundle' },
      type: 'document',
      timestamp: '2025-01-01T00:00:00Z',
      entry: [
        FHIR::Bundle::Entry.new(fullUrl: 'urn:uuid:composition-1', resource: build_composition),
        FHIR::Bundle::Entry.new(fullUrl: patient_full_url, resource: build_patient)
      ]
    )
  end

  def build_patient
    FHIR::Patient.new(
      resourceType: 'Patient',
      id: 'patient-1',
      name: [{ family: 'Smith', given: ['Jane'] }],
      gender: 'female',
      birthDate: '1975-04-12'
    )
  end

  def build_composition
    FHIR::Composition.new(
      resourceType: 'Composition',
      id: 'composition-1',
      status: 'final',
      type: { coding: [{ system: 'http://loinc.org', code: '60591-5' }] },
      subject: { reference: patient_full_url },
      author: [{ reference: 'urn:uuid:practitioner-1' }],
      title: 'Test Australian Patient Summary'
    )
  end

  def create_subject_resource_type_test(test_id)
    klass = Class.new(AUPSTestKit::BasicTest) do
      id test_id
      run { test_resource_type_is_valid?('subject') }
      define_method(:metadata_manager) do
        @metadata_manager ||= AUPSTestKit::MetadataManager.new(BUNDLE_SCRATCH_FIXTURE_METADATA_PATH)
      end
    end
    repo = Inferno::Repositories::Tests.new
    repo.insert(klass) unless repo.exists?(test_id)
    klass
  end

  describe 'per-group scratch keys' do
    it 'reads the Bundle stored under its own group key' do
      test = create_subject_resource_type_test('suite_au_ps_bundle_instance_scratch_own_key_test')
      result = run(test, {}, { bundle_ips_resource_instance: build_bundle })

      expect(result.result).to eq('pass')
    end

    it 'omits instead of reading a Bundle acquired by a different group' do
      test = create_subject_resource_type_test('suite_retrieve_au_ps_bundle_validation_tests_scratch_leak_test')
      result = run(test, {}, { bundle_ips_resource_instance: build_bundle })

      expect(result.result).to eq('omit')
    end

    it 'derives the summary group key from the test id' do
      test = create_subject_resource_type_test(
        'suite_generate_au_ps_using_ips_summary_validation_tests_scratch_key_test'
      )
      result = run(test, {}, { bundle_ips_resource_summary: build_bundle })

      expect(result.result).to eq('pass')
    end
  end

  describe 'no-input handling' do
    it 'omits (not fails) the subject resource-type test when no Bundle was loaded' do
      test = create_subject_resource_type_test('suite_au_ps_bundle_instance_scratch_no_input_test')
      result = run(test, {}, {})

      expect(result.result).to eq('omit')
      expect(result.result_message).to match(/No AU PS Bundle was loaded by this test group/)
    end
  end
end
