# frozen_string_literal: true

require 'fhir_models'
require 'json'

require_relative '../../../lib/au_ps_inferno/utils/basic_test_class'
require_relative '../../../lib/au_ps_inferno/utils/metadata_manager'

require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

SUBJECT_MS_SUB_ELEMENTS_FIXTURE_METADATA_PATH = File.expand_path('../../fixtures/metadata.yaml', __dir__).freeze

RSpec.describe 'Subject Must Support sub-elements populated (test 1.8.03)' do
  include_context 'when testing a runnable'

  let(:suite_id) { 'subject_ms_sub_elements_test_suite' }
  let(:patient_full_url) { 'urn:uuid:patient-1' }

  before do
    suite_stub = Class.new(Inferno::TestSuite) { id 'subject_ms_sub_elements_test_suite' }
    repo = Inferno::Repositories::TestSuites.new
    repo.insert(suite_stub) unless repo.exists?('subject_ms_sub_elements_test_suite')
  end

  def build_bundle(patient_resource)
    FHIR::Bundle.new(
      resourceType: 'Bundle',
      identifier: { system: 'urn:ietf:rfc:3986', value: 'urn:uuid:test-subject-ms-sub-elements-bundle' },
      type: 'document',
      timestamp: '2025-01-01T00:00:00Z',
      entry: bundle_entries(patient_resource)
    )
  end

  def bundle_entries(patient_resource)
    [
      FHIR::Bundle::Entry.new(fullUrl: 'urn:uuid:composition-1', resource: build_composition),
      FHIR::Bundle::Entry.new(fullUrl: patient_full_url, resource: patient_resource)
    ]
  end

  def build_composition
    FHIR::Composition.new(
      resourceType: 'Composition',
      id: 'composition-1',
      status: 'final',
      type: { coding: [{ system: 'http://loinc.org', code: '60591-5' }] },
      subject: { reference: patient_full_url },
      author: [{ reference: 'urn:uuid:practitioner-1' }],
      title: 'Test Australian Patient Summary',
      custodian: { reference: 'urn:uuid:org-1' }
    )
  end

  def create_subject_ms_sub_elements_test(test_id)
    klass = Class.new(AUPSTestKit::BasicTest) do
      id test_id
      run { ms_sub_elements_populated_message('subject') }
      define_method(:metadata_manager) do
        @metadata_manager ||= AUPSTestKit::MetadataManager.new(SUBJECT_MS_SUB_ELEMENTS_FIXTURE_METADATA_PATH)
      end
    end
    repo = Inferno::Repositories::Tests.new
    repo.insert(klass) unless repo.exists?(test_id)
    klass
  end

  def scratch_for(bundle)
    {
      bundle_ips_resource: bundle,
      bundle_entities: bundle.entry.map do |e|
        { full_url: e.fullUrl, resource_type: e.resource.resourceType, resource: e.resource }
      end
    }
  end

  describe 'ms_sub_elements_populated_message (test 1.8.03)' do
    # RED test for issue #78: when communication is present but communication.language (mandatory
    # sub-element) is missing, the test should fail. Currently passes because assert_result receives
    # filtered_results (sub-elements only) instead of full results, so the parent 'communication' is
    # never found and sub_element_assertion_failure? always returns false.
    skip 'fails when a mandatory MS sub-element is missing but its parent element is present (issue #78)' do
      patient = FHIR::Patient.new(
        resourceType: 'Patient',
        id: 'patient-1',
        name: [{ family: 'Smith', given: ['Jane'] }],
        gender: 'female',
        birthDate: '1975-04-12',
        communication: [{ preferred: true }]
      )

      test = create_subject_ms_sub_elements_test('subject_ms_sub_elements_fail_test')
      result = run(test, {}, scratch_for(build_bundle(patient)))

      expect(result.result).to eq('fail')
    end

    it 'passes when all mandatory MS sub-elements are populated' do
      patient = FHIR::Patient.new(
        resourceType: 'Patient',
        id: 'patient-1',
        name: [{ family: 'Smith', given: ['Jane'] }],
        gender: 'female',
        birthDate: '1975-04-12',
        communication: [{
          language: { coding: [{ system: 'urn:ietf:bcp:47', code: 'en' }] },
          preferred: true
        }]
      )

      test = create_subject_ms_sub_elements_test('subject_ms_sub_elements_pass_test')
      result = run(test, {}, scratch_for(build_bundle(patient)))

      expect(result.result).to eq('pass')
    end
  end
end
