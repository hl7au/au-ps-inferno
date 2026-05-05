# frozen_string_literal: true

require 'fhir_models'

require_relative '../../support/basic_test/composition_sections_check_support'
require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

# rubocop:disable Layout/LineLength
RSpec.describe AUPSTestKit::BasicTestCompositionSectionReadModule do # rubocop:disable Metrics/BlockLength
  include_context 'when testing a runnable'
  include_context 'composition sections check setup'

  describe 'Composition Sections Check - Mandatory Sections' do # rubocop:disable Metrics/BlockLength
    let(:test) { find_test(:test_composition_mandatory_sections) }
    let(:metadata) do # rubocop:disable Metrics/BlockLength
      {
        composition_sections: [
          {
            code: '11450-4',
            short: 'Patient Summary Problems Section',
            entries: [
              { profiles: ['Condition|http://hl7.org/fhir/StructureDefinition/Condition',
                           'DocumentReference|http://hl7.org/fhir/StructureDefinition/DocumentReference'] },
              { profiles: ['Condition|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition'] }
            ]
          },
          {
            code: '48765-2',
            short: 'Patient Summary Allergies and Intolerances Section',
            entries: [
              { profiles: ['AllergyIntolerance|http://hl7.org/fhir/StructureDefinition/AllergyIntolerance',
                           'DocumentReference|http://hl7.org/fhir/StructureDefinition/DocumentReference'] },
              { profiles: ['AllergyIntolerance|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-allergyintolerance'] }
            ]
          },
          {
            code: '10160-0',
            short: 'Patient Summary Medication Summary Section',
            entries: [
              { profiles: ['MedicationStatement|http://hl7.org/fhir/StructureDefinition/MedicationStatement',
                           'MedicationRequest|http://hl7.org/fhir/StructureDefinition/MedicationRequest'] },
              { profiles: ['MedicationStatement|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement',
                           'MedicationRequest|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationrequest'] }
            ]
          }
        ],
        groups: [
          {
            resource: 'Condition',
            must_supports: {
              elements: [
                { path: 'category' },
                { path: 'code' },
                { path: 'subject' },
                { path: 'subject.reference' }
              ]
            },
            mandatory_elements: %w[
              Condition.category
              Condition.code
              Condition.subject
              Condition.subject.reference
            ]
          }
        ]
      }
    end

    let(:au_ps_warnings) do
      [
        { type: 'warning',
          text: "**Profile**: Condition — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition\n\n**Message**: No resources found" },
        { type: 'warning',
          text: "**Profile**: AllergyIntolerance — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-allergyintolerance\n\n**Message**: No resources found" },
        { type: 'warning',
          text: "**Profile**: MedicationStatement — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement\n\n**Message**: No resources found" },
        { type: 'warning',
          text: "**Profile**: MedicationRequest — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationrequest\n\n**Message**: No resources found" }
      ]
    end

    before { configure_test_class(test, metadata) }

    it 'passes when all mandatory sections are present' do
      bundle = build_bundle(sections: [
                              section_without_entries('11450-4'),
                              section_without_entries('48765-2'),
                              section_without_entries('10160-0')
                            ])
      result, messages = run_bundle(bundle)

      expect(result.result).to eq('pass'), result.result_message
      expect_messages(messages, [
        { type: 'info',
          text: "Patient Summary Problems Section (11450-4)\n\nNo entries; no emptyReason." },
        { type: 'info',
          text: "Patient Summary Allergies and Intolerances Section (48765-2)\n\nNo entries; no emptyReason." },
        { type: 'info',
          text: "Patient Summary Medication Summary Section (10160-0)\n\nNo entries; no emptyReason." }
      ] + au_ps_warnings)
    end

    it 'passes when a section has an emptyReason instead of entries' do
      bundle = build_bundle(sections: [
                              section_with_empty_reason('11450-4', display: 'Withheld', reason_code: 'withheld'),
                              section_without_entries('48765-2'),
                              section_without_entries('10160-0')
                            ])
      result, messages = run_bundle(bundle)

      expect(result.result).to eq('pass'), result.result_message
      expect_messages(messages, [
        { type: 'info',
          text: "Patient Summary Problems Section (11450-4)\n\nemptyReason: Withheld (withheld)" },
        { type: 'info',
          text: "Patient Summary Allergies and Intolerances Section (48765-2)\n\nNo entries; no emptyReason." },
        { type: 'info',
          text: "Patient Summary Medication Summary Section (10160-0)\n\nNo entries; no emptyReason." }
      ] + au_ps_warnings)
    end

    it 'fails when a mandatory section is absent from the composition' do
      bundle = build_bundle(sections: [
                              section_without_entries('48765-2'),
                              section_without_entries('10160-0')
                            ])
      result, messages = run_bundle(bundle)

      expect(result.result).to eq('fail')
      expect_messages(messages, [
        { type: 'error',
          text: "Patient Summary Problems Section (11450-4)\n\nNo composition section found for code: 11450-4" },
        { type: 'info',
          text: "Patient Summary Allergies and Intolerances Section (48765-2)\n\nNo entries; no emptyReason." },
        { type: 'info',
          text: "Patient Summary Medication Summary Section (10160-0)\n\nNo entries; no emptyReason." }
      ] + au_ps_warnings)
    end

    it 'fails when a section entry reference does not resolve' do
      bundle = build_bundle(sections: [
                              section_with_entry('11450-4', 'urn:uuid:missing-condition-1'),
                              section_without_entries('48765-2'),
                              section_without_entries('10160-0')
                            ])
      result, messages = run_bundle(bundle)

      expect(result.result).to eq('fail')
      expect_messages(messages, [
        { type: 'error',
          text: "Patient Summary Problems Section (11450-4)\n\n**urn:uuid:missing-condition-1** -> ❌ Reference does not resolve" },
        { type: 'info',
          text: "Patient Summary Allergies and Intolerances Section (48765-2)\n\nNo entries; no emptyReason." },
        { type: 'info',
          text: "Patient Summary Medication Summary Section (10160-0)\n\nNo entries; no emptyReason." }
      ] + au_ps_warnings)
    end

    it 'passes when a section entry reference resolves with no meta.profile' do
      condition_entry = FHIR::Bundle::Entry.new(
        fullUrl: 'urn:uuid:condition-1',
        resource: FHIR::Condition.new(
          resourceType: 'Condition',
          category: [{ coding: [{ code: 'problem-list-item' }] }],
          code: { coding: [{ code: '160245001' }] },
          subject: { reference: 'urn:uuid:patient-1' }
        )
      )
      bundle = build_bundle(
        sections: [
          section_with_entry('11450-4', 'urn:uuid:condition-1'),
          section_without_entries('48765-2'),
          section_without_entries('10160-0')
        ],
        extra_entries: [condition_entry]
      )
      result, messages = run_bundle(bundle)
      expect(result.result).to eq('pass'), result.result_message
      expect(messages).to include_message(
        type: 'info',
        text: "Patient Summary Problems Section (11450-4)\n\nentry[0]: **urn:uuid:condition-1** -> Condition (no meta.profile)"
      )
    end

    it 'passes when a section entry reference resolves with meta.profile' do
      condition_entry = FHIR::Bundle::Entry.new(
        fullUrl: 'urn:uuid:condition-1',
        resource: FHIR::Condition.new(
          resourceType: 'Condition',
          meta: { profile: ['http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition'] },
          category: [{ coding: [{ code: 'problem-list-item' }] }],
          code: { coding: [{ code: '160245001' }] },
          subject: { reference: 'urn:uuid:patient-1' }
        )
      )
      bundle = build_bundle(
        sections: [
          section_with_entry('11450-4', 'urn:uuid:condition-1'),
          section_without_entries('48765-2'),
          section_without_entries('10160-0')
        ],
        extra_entries: [condition_entry]
      )
      result, messages = run_bundle(bundle)
      expect(result.result).to eq('pass'), result.result_message
      expect(messages).to include_message(
        type: 'info',
        text: "Patient Summary Problems Section (11450-4)\n\nentry[0]: **urn:uuid:condition-1** -> Condition (meta.profile: http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition)"
      )
    end

    it 'fails when a section entry references a resource of the wrong type' do
      observation_entry = FHIR::Bundle::Entry.new(
        fullUrl: 'urn:uuid:observation-1',
        resource: FHIR::Observation.new(resourceType: 'Observation', status: 'final',
                                        code: { coding: [{ code: '1234-5' }] })
      )
      bundle = build_bundle(
        sections: [
          section_with_entry('11450-4', 'urn:uuid:observation-1'),
          section_without_entries('48765-2'),
          section_without_entries('10160-0')
        ],
        extra_entries: [observation_entry]
      )
      result, messages = run_bundle(bundle)

      expect(result.result).to eq('fail')
      expect_messages(messages, [
        { type: 'error',
          text: "Patient Summary Problems Section (11450-4)\n\nentry[0]: **urn:uuid:observation-1** -> ❌ Invalid resource type" },
        { type: 'info',
          text: "Patient Summary Allergies and Intolerances Section (48765-2)\n\nNo entries; no emptyReason." },
        { type: 'info',
          text: "Patient Summary Medication Summary Section (10160-0)\n\nNo entries; no emptyReason." }
      ] + au_ps_warnings)
    end

    it 'fails when section entries mix resolved and unresolved references' do # rubocop:disable Metrics/BlockLength
      condition_entry = FHIR::Bundle::Entry.new(
        fullUrl: 'urn:uuid:condition-1',
        resource: FHIR::Condition.new(
          resourceType: 'Condition',
          category: [{ coding: [{ code: 'problem-list-item' }] }],
          code: { coding: [{ code: '160245001' }] },
          subject: { reference: 'urn:uuid:patient-1' }
        )
      )
      bundle = build_bundle(
        sections: [
          {
            code: { coding: [{ code: '11450-4' }] },
            entry: [
              { reference: 'urn:uuid:condition-1' },
              { reference: 'urn:uuid:missing-2' }
            ]
          },
          section_without_entries('48765-2'),
          section_without_entries('10160-0')
        ],
        extra_entries: [condition_entry]
      )
      result, messages = run_bundle(bundle)
      problems_section_message = messages.find do |message|
        message.type == 'error' && message.message.start_with?('Patient Summary Problems Section (11450-4)')
      end

      expect(result.result).to eq('fail')
      expect(problems_section_message).not_to be_nil
      expect(problems_section_message.message).to include('entry[0]: **urn:uuid:condition-1** -> Condition (no meta.profile)')
      expect(problems_section_message.message).to include('**urn:uuid:missing-2** -> ❌ Reference does not resolve')
    end

    it 'fails when all mandatory sections are absent from the composition' do
      bundle = build_bundle(sections: [])
      result, messages = run_bundle(bundle)

      expect(result.result).to eq('fail')
      expect_messages(messages, [
        { type: 'error',
          text: "Patient Summary Problems Section (11450-4)\n\nNo composition section found for code: 11450-4" },
        { type: 'error',
          text: "Patient Summary Allergies and Intolerances Section (48765-2)\n\nNo composition section found for code: 48765-2" },
        { type: 'error',
          text: "Patient Summary Medication Summary Section (10160-0)\n\nNo composition section found for code: 10160-0" }
      ] + au_ps_warnings)
    end

    it 'skips when no bundle is provided in scratch' do
      result = run_test({})

      expect(result.result).to eq('skip')
      expect(messages_for(result)).to be_empty
    end
  end
end
# rubocop:enable Layout/LineLength
