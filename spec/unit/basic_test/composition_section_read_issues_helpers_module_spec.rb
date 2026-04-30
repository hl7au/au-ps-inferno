# frozen_string_literal: true

require 'json'
require 'fhir_models'

require_relative '../../../lib/au_ps_inferno/utils/basic_test/composition_section_read_issues_helpers_module'
require_relative '../../../lib/au_ps_inferno/utils/bundle_decorator'
require_relative '../../support/basic_test/references_resolution_report_spec_support'

RSpec.describe AUPSTestKit::BasicTestCompositionSectionReadIssuesHelpersModule do
  include_context 'references resolution report setup'

  section_code = '11450-4'
  section_metadata = {
    code: section_code,
    entries: [
      {
        profiles: [
          'Condition|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition|1.0.0-ballot'
        ]
      }
    ]
  }
  condition_resource = {
    fullUrl: 'urn:uuid:condition-1',
    resource: {
      resourceType: 'Condition',
      subject: { reference: 'urn:uuid:patient-1' },
      code: { coding: [{ system: 'http://snomed.info/sct', code: '160245001' }] }
    }
  }

  describe '#references_resolution_report' do
    it 'returns one report item per section entry reference' do
      bundle = build_bundle(section_code: section_code, references: ['urn:uuid:condition-1'],
                            resources: [condition_resource])
      result = test_instance.references_resolution_report(section_metadata, bundle)

      expect(result.size).to eq(1)
      expect(result.first[:reference]).to eq('urn:uuid:condition-1')
    end

    it 'marks report item as resolved when reference exists and type is permitted' do
      bundle = build_bundle(section_code: section_code, references: ['urn:uuid:condition-1'],
                            resources: [condition_resource])
      result = test_instance.references_resolution_report(section_metadata, bundle)

      expect(result.first).to eq(
        {
          reference: 'urn:uuid:condition-1',
          resolved: true,
          issues: []
        }
      )
    end

    it 'marks report item unresolved with not-found issue when resource is missing' do
      bundle = build_bundle(section_code: section_code, references: ['urn:uuid:condition-1'], resources: [])
      result = test_instance.references_resolution_report(section_metadata, bundle)

      expect(result.first).to eq(
        {
          reference: 'urn:uuid:condition-1',
          resolved: false,
          issues: ['Resource not found for reference: urn:uuid:condition-1']
        }
      )
    end

    it 'marks report item unresolved with invalid-type issue when resource type is not permitted' do
      observation_resource = {
        fullUrl: 'urn:uuid:condition-1',
        resource: { resourceType: 'Observation', status: 'final', code: { coding: [{ code: '1234-5' }] } }
      }
      bundle = build_bundle(section_code: section_code, references: ['urn:uuid:condition-1'],
                            resources: [observation_resource])
      result = test_instance.references_resolution_report(section_metadata, bundle)

      expect(result.first[:resolved]).to be(false)
      expect(result.first[:issues]).to eq(
        ['Resource type: Observation is not in the list of expected resource types: ["Condition"]']
      )
    end

    it 'returns mixed report items preserving entry order when section has multiple references' do
      bundle = build_bundle(section_code: section_code, references: ['urn:uuid:condition-1', 'urn:uuid:condition-2'],
                            resources: [condition_resource])
      result = test_instance.references_resolution_report(section_metadata, bundle)

      expect(result).to eq(
        [
          { reference: 'urn:uuid:condition-1', resolved: true, issues: [] },
          { reference: 'urn:uuid:condition-2', resolved: false,
            issues: ['Resource not found for reference: urn:uuid:condition-2'] }
        ]
      )
    end

    it 'uses unique resource types from profile prefixes when profiles include duplicates and versions' do
      deduped_metadata = {
        code: section_code,
        entries: [
          {
            profiles: [
              'Condition|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition|1.0.0-ballot',
              'Condition|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition|1.0.1'
            ]
          }
        ]
      }
      bundle = build_bundle(section_code: section_code, references: ['urn:uuid:condition-1'],
                            resources: [condition_resource])
      result = test_instance.references_resolution_report(deduped_metadata, bundle)

      expect(result.first[:resolved]).to be(true)
      expect(result.first[:issues]).to eq([])
    end
  end
end
