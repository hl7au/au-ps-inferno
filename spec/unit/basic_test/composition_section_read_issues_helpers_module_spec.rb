# frozen_string_literal: true

require 'json'
require 'fhir_models'

require_relative '../../../lib/au_ps_inferno/utils/basic_test/composition_section_read_issues_helpers_module'
require_relative '../../../lib/au_ps_inferno/utils/bundle_decorator'
require_relative '../../support/basic_test/references_resolution_report_spec_support'

RSpec.describe AUPSTestKit::BasicTestCompositionSectionReadIssuesHelpersModule do
  include_context 'references resolution report setup'

  describe '#references_resolution_report' do
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
    it 'returns one report item per section entry reference' do
      bundle = build_section_bundle(section_code: section_code, references: ['urn:uuid:condition-1'],
                                    bundle_entries: [condition_entry])
      result = test_instance.references_resolution_report(section_metadata, bundle)

      expect(result.size).to eq(1)
      expect(result.first[:reference]).to eq('urn:uuid:condition-1')
    end

    it 'marks report item as resolved when reference exists and type is permitted' do
      bundle = build_section_bundle(section_code: section_code, references: ['urn:uuid:condition-1'],
                                    bundle_entries: [condition_entry])
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
      bundle = build_section_bundle(section_code: section_code, references: ['urn:uuid:condition-1'],
                                    bundle_entries: [])
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
      bundle = build_section_bundle(section_code: section_code, references: ['urn:uuid:condition-1'],
                                    bundle_entries: [observation_entry(url: 'urn:uuid:condition-1')])
      result = test_instance.references_resolution_report(section_metadata, bundle)

      expect(result.first[:resolved]).to be(false)
      expect(result.first[:issues]).to eq(
        ['Resource type: Observation is not in the list of expected resource types: ["Condition"]']
      )
    end

    it 'returns mixed report items preserving entry order when section has multiple references' do
      bundle = build_section_bundle(
        section_code: section_code,
        references: ['urn:uuid:condition-1', 'urn:uuid:condition-2'],
        bundle_entries: [condition_entry]
      )
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
      bundle = build_section_bundle(section_code: section_code, references: ['urn:uuid:condition-1'],
                                    bundle_entries: [condition_entry])
      result = test_instance.references_resolution_report(deduped_metadata, bundle)

      expect(result.first[:resolved]).to be(true)
      expect(result.first[:issues]).to eq([])
    end

    it 'returns an empty array when the section has no entry references' do
      bundle = build_section_bundle(section_code: section_code, references: [], bundle_entries: [])
      result = test_instance.references_resolution_report(section_metadata, bundle)

      expect(result).to be_empty
    end

    it 'returns one item per entry preserving order when section has three references' do
      bundle = build_section_bundle(
        section_code: section_code,
        references: ['urn:uuid:condition-1', 'urn:uuid:condition-2', 'urn:uuid:condition-3'],
        bundle_entries: [condition_entry(url: 'urn:uuid:condition-1'), condition_entry(url: 'urn:uuid:condition-2')]
      )
      result = test_instance.references_resolution_report(section_metadata, bundle)

      expect(result.size).to eq(3)
      expect(result[0]).to eq({ reference: 'urn:uuid:condition-1', resolved: true, issues: [] })
      expect(result[1]).to eq({ reference: 'urn:uuid:condition-2', resolved: true, issues: [] })
      expect(result[2]).to eq({ reference: 'urn:uuid:condition-3', resolved: false,
                                issues: ['Resource not found for reference: urn:uuid:condition-3'] })
    end

    it 'resolves correctly when profile format omits the version suffix' do
      two_part_metadata = {
        code: section_code,
        entries: [{ profiles: ['Condition|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition'] }]
      }
      bundle = build_section_bundle(section_code: section_code, references: ['urn:uuid:condition-1'],
                                    bundle_entries: [condition_entry(url: 'urn:uuid:condition-1')])
      result = test_instance.references_resolution_report(two_part_metadata, bundle)

      expect(result.first[:resolved]).to be(true)
      expect(result.first[:issues]).to be_empty
    end

    it 'marks reference as wrong type when profile string is a bare URL without a type prefix' do
      url_only_metadata = {
        code: section_code,
        entries: [{ profiles: ['http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition'] }]
      }
      bundle = build_section_bundle(section_code: section_code, references: ['urn:uuid:condition-1'],
                                    bundle_entries: [condition_entry(url: 'urn:uuid:condition-1')])
      result = test_instance.references_resolution_report(url_only_metadata, bundle)

      expect(result.first[:resolved]).to be(false)
      expect(result.first[:issues].first).to include('is not in the list of expected resource types')
    end

    # Issue #74 sub-case: absolute URL reference with /_history/{version} suffix
    context 'when reference is an absolute URL with a /_history/ version suffix' do
      let(:base_url) { 'https://example.org' }

      it 'resolves against the entry whose fullUrl is the same URL without the history suffix' do
        bundle = build_section_bundle(
          section_code: section_code,
          references: ["#{base_url}/Condition/condition-1/_history/2"],
          bundle_entries: [condition_entry(url: "#{base_url}/Condition/condition-1")]
        )
        result = test_instance.references_resolution_report(section_metadata, bundle)

        expect(result.first[:resolved]).to be(true)
        expect(result.first[:issues]).to be_empty
      end

      it 'reports not-found when no entry matches the URL without the history suffix' do
        bundle = build_section_bundle(
          section_code: section_code,
          references: ["#{base_url}/Condition/missing/_history/2"],
          bundle_entries: [condition_entry(url: "#{base_url}/Condition/condition-1")]
        )
        result = test_instance.references_resolution_report(section_metadata, bundle)

        expect(result.first[:resolved]).to be(false)
        expect(result.first[:issues]).to eq(
          ["Resource not found for reference: #{base_url}/Condition/missing/_history/2"]
        )
      end
    end

    # Issue #74: relative references against absolute fullUrls
    context 'when Composition fullUrl is URN and entry fullUrl is absolute (issue #74)' do
      let(:base_url) { 'https://example.org' }

      it 'resolves a relative reference when the matching entry has an absolute fullUrl' do
        bundle = build_section_bundle(
          section_code: section_code,
          references: ['Condition/condition-1'],
          bundle_entries: [condition_entry(url: "#{base_url}/Condition/condition-1")]
        )
        result = test_instance.references_resolution_report(section_metadata, bundle)

        expect(result.first[:resolved]).to be(true)
        expect(result.first[:issues]).to be_empty
      end

      it 'reports not-found when the relative reference has no matching absolute fullUrl' do
        bundle = build_section_bundle(
          section_code: section_code,
          references: ['Condition/condition-1'],
          bundle_entries: [condition_entry(url: "#{base_url}/Condition/condition-2")]
        )
        result = test_instance.references_resolution_report(section_metadata, bundle)

        expect(result.first[:resolved]).to be(false)
        expect(result.first[:issues]).to eq(['Resource not found for reference: Condition/condition-1'])
      end

      it 'resolves relative references alongside URN-based references in the same section' do
        bundle = build_section_bundle(
          section_code: section_code,
          references: ['urn:uuid:condition-1', 'Condition/condition-2'],
          bundle_entries: [
            condition_entry(url: 'urn:uuid:condition-1'),
            condition_entry(url: "#{base_url}/Condition/condition-2")
          ]
        )
        result = test_instance.references_resolution_report(section_metadata, bundle)

        expect(result[0]).to eq({ reference: 'urn:uuid:condition-1', resolved: true, issues: [] })
        expect(result[1]).to eq({ reference: 'Condition/condition-2', resolved: true, issues: [] })
      end
    end
  end
end
