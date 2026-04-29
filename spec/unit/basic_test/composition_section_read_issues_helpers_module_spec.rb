# frozen_string_literal: true

require 'json'
require 'fhir_models'

require_relative '../../../lib/au_ps_inferno/utils/basic_test/composition_section_read_issues_helpers_module'
require_relative '../../../lib/au_ps_inferno/utils/bundle_decorator'

RSpec.describe AUPSTestKit::BasicTestCompositionSectionReadIssuesHelpersModule do
  let(:test_class) do
    Class.new do
      include AUPSTestKit::BasicTestCompositionSectionReadIssuesHelpersModule
    end
  end

  let(:test_instance) { test_class.new }
  let(:section_code) { '11450-4' }
  let(:section_metadata) do
    {
      code: section_code,
      entries: [
        {
          profiles: [
            'Condition|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition|1.0.0-ballot'
          ]
        }
      ]
    }
  end

  let(:references) { ['urn:uuid:condition-1'] }
  let(:resources) do
    [
      {
        fullUrl: 'urn:uuid:condition-1',
        resource: {
          resourceType: 'Condition',
          subject: { reference: 'urn:uuid:patient-1' },
          code: { coding: [{ system: 'http://snomed.info/sct', code: '160245001' }] }
        }
      }
    ]
  end
  let(:bundle_resource) do
    raw_bundle = JSON.parse(JSON.generate(build_bundle_hash(references: references, resources: resources)))
    fhir_bundle = FHIR::Bundle.new(raw_bundle)
    BundleDecorator.new(fhir_bundle)
  end

  let(:result) { test_instance.send(:references_resolution_report, section_metadata, bundle_resource) }

  def build_bundle_hash(references:, resources:)
    {
      resourceType: 'Bundle',
      type: 'document',
      entry: [
        {
          fullUrl: 'urn:uuid:composition-1',
          resource: {
            resourceType: 'Composition',
            status: 'final',
            type: { coding: [{ code: '60591-5' }] },
            subject: { reference: 'urn:uuid:patient-1' },
            date: '2024-01-01T00:00:00Z',
            author: [{ reference: 'urn:uuid:author-1' }],
            title: 'Test Composition',
            section: [
              {
                code: { coding: [{ code: section_code }] },
                entry: references.map { |reference| { reference: reference } }
              }
            ]
          }
        },
        {
          fullUrl: 'urn:uuid:patient-1',
          resource: {
            resourceType: 'Patient'
          }
        },
        {
          fullUrl: 'urn:uuid:author-1',
          resource: {
            resourceType: 'Practitioner'
          }
        },
        *resources
      ]
    }
  end

  describe '#references_resolution_report' do
    it 'returns one report item per section entry reference' do
      expect(result.size).to eq(1)
      expect(result.first[:reference]).to eq('urn:uuid:condition-1')
    end

    it 'marks report item as resolved when reference exists and type is permitted' do
      expect(result.first).to eq(
        {
          reference: 'urn:uuid:condition-1',
          resolved: true,
          issues: []
        }
      )
    end

    context 'when referenced resource is missing' do
      let(:resources) { [] }

      it 'marks report item unresolved with not-found issue' do
        expect(result.first).to eq(
          {
            reference: 'urn:uuid:condition-1',
            resolved: false,
            issues: ['Resource not found for reference: urn:uuid:condition-1']
          }
        )
      end
    end

    context 'when referenced resource type is not permitted' do
      let(:resources) do
        [
          {
            fullUrl: 'urn:uuid:condition-1',
            resource: {
              resourceType: 'Observation',
              status: 'final',
              code: { coding: [{ code: '1234-5' }] }
            }
          }
        ]
      end

      it 'marks report item unresolved with invalid-type issue' do
        expect(result.first[:resolved]).to be(false)
        expect(result.first[:issues]).to eq(
          ['Resource type: Observation is not in the list of expected resource types: ["Condition"]']
        )
      end
    end

    context 'when section has multiple references' do
      let(:references) { ['urn:uuid:condition-1', 'urn:uuid:condition-2'] }
      let(:resources) do
        [
          {
            fullUrl: 'urn:uuid:condition-1',
            resource: {
              resourceType: 'Condition',
              subject: { reference: 'urn:uuid:patient-1' },
              code: { coding: [{ system: 'http://snomed.info/sct', code: '160245001' }] }
            }
          }
        ]
      end

      it 'returns mixed report items preserving entry order' do
        expect(result).to eq(
          [
            {
              reference: 'urn:uuid:condition-1',
              resolved: true,
              issues: []
            },
            {
              reference: 'urn:uuid:condition-2',
              resolved: false,
              issues: ['Resource not found for reference: urn:uuid:condition-2']
            }
          ]
        )
      end
    end

    context 'when permitted profiles include duplicates and versions' do
      let(:section_metadata) do
        {
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
      end

      it 'uses unique resource types extracted from profile prefixes' do
        expect(result.first[:resolved]).to be(true)
        expect(result.first[:issues]).to eq([])
      end
    end
  end
end
