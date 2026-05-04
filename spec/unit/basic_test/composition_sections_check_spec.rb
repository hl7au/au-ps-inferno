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
        have_attributes(type: 'warning',
                        message: "**Profile**: Condition — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition\n\n**Message**: No resources found"),
        have_attributes(type: 'warning',
                        message: "**Profile**: AllergyIntolerance — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-allergyintolerance\n\n**Message**: No resources found"),
        have_attributes(type: 'warning',
                        message: "**Profile**: MedicationStatement — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement\n\n**Message**: No resources found"),
        have_attributes(type: 'warning',
                        message: "**Profile**: MedicationRequest — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationrequest\n\n**Message**: No resources found")
      ]
    end

    before { configure_test_class(test, metadata) }

    it 'passes when all mandatory sections are present' do
      bundle = build_bundle(sections: [
                              section_without_entries('11450-4'),
                              section_without_entries('48765-2'),
                              section_without_entries('10160-0')
                            ])
      result = run_test(scratch_with(bundle))
      messages = messages_for(result)

      expect(result.result).to eq('pass'), result.result_message
      expect(messages).to match_array(
        [
          have_attributes(type: 'info',
                          message: "Patient Summary Problems Section (11450-4)\n\nNo entries; no emptyReason."),
          have_attributes(type: 'info',
                          message: "Patient Summary Allergies and Intolerances Section (48765-2)\n\nNo entries; no emptyReason."),
          have_attributes(type: 'info',
                          message: "Patient Summary Medication Summary Section (10160-0)\n\nNo entries; no emptyReason.")
        ] + au_ps_warnings
      )
    end

    it 'fails when a mandatory section is absent from the composition' do
      bundle = build_bundle(sections: [
                              section_without_entries('48765-2'),
                              section_without_entries('10160-0')
                            ])
      result = run_test(scratch_with(bundle))
      messages = messages_for(result)

      expect(result.result).to eq('fail')
      expect(messages).to match_array(
        [
          have_attributes(type: 'error',
                          message: "Patient Summary Problems Section (11450-4)\n\nNo composition section found for code: 11450-4"),
          have_attributes(type: 'info',
                          message: "Patient Summary Allergies and Intolerances Section (48765-2)\n\nNo entries; no emptyReason."),
          have_attributes(type: 'info',
                          message: "Patient Summary Medication Summary Section (10160-0)\n\nNo entries; no emptyReason.")
        ] + au_ps_warnings
      )
    end

    it 'fails when a section entry reference does not resolve' do
      bundle = build_bundle(sections: [
                              section_with_entry('11450-4', 'urn:uuid:missing-condition-1'),
                              section_without_entries('48765-2'),
                              section_without_entries('10160-0')
                            ])
      result = run_test(scratch_with(bundle))
      messages = messages_for(result)

      expect(result.result).to eq('fail')
      expect(messages).to match_array(
        [
          have_attributes(type: 'error',
                          message: "Patient Summary Problems Section (11450-4)\n\n**urn:uuid:missing-condition-1** -> ❌ Reference does not resolve"),
          have_attributes(type: 'info',
                          message: "Patient Summary Allergies and Intolerances Section (48765-2)\n\nNo entries; no emptyReason."),
          have_attributes(type: 'info',
                          message: "Patient Summary Medication Summary Section (10160-0)\n\nNo entries; no emptyReason.")
        ] + au_ps_warnings
      )
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
      result = run_test(scratch_with(bundle))
      messages = messages_for(result)
      problems_section_message = messages.find do |message|
        message.type == 'info' && message.message.start_with?('Patient Summary Problems Section (11450-4)')
      end

      expect(result.result).to eq('pass'), result.result_message
      expect(problems_section_message).to have_attributes(
        type: 'info',
        message: "Patient Summary Problems Section (11450-4)\n\nentry[0]: **urn:uuid:condition-1** -> Condition (no meta.profile)"
      )
    end

    it 'fails when a section entry references a resource of the wrong type' do # rubocop:disable Metrics/BlockLength
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
      result = run_test(scratch_with(bundle))
      messages = messages_for(result)

      expect(result.result).to eq('fail')
      expect(messages).to match_array(
        [
          have_attributes(type: 'error',
                          message: "Patient Summary Problems Section (11450-4)\n\nentry[0]: **urn:uuid:observation-1** -> ❌ Invalid resource type"),
          have_attributes(type: 'info',
                          message: "Patient Summary Allergies and Intolerances Section (48765-2)\n\nNo entries; no emptyReason."),
          have_attributes(type: 'info',
                          message: "Patient Summary Medication Summary Section (10160-0)\n\nNo entries; no emptyReason.")
        ] + au_ps_warnings
      )
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
      result = run_test(scratch_with(bundle))
      messages = messages_for(result)
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
      result = run_test(scratch_with(bundle))
      messages = messages_for(result)

      expect(result.result).to eq('fail')
      expect(messages).to match_array(
        [
          have_attributes(type: 'error',
                          message: "Patient Summary Problems Section (11450-4)\n\nNo composition section found for code: 11450-4"),
          have_attributes(type: 'error',
                          message: "Patient Summary Allergies and Intolerances Section (48765-2)\n\nNo composition section found for code: 48765-2"),
          have_attributes(type: 'error',
                          message: "Patient Summary Medication Summary Section (10160-0)\n\nNo composition section found for code: 10160-0")
        ] + au_ps_warnings
      )
    end

    it 'skips when no bundle is provided in scratch' do
      result = run_test({})

      expect(result.result).to eq('skip')
      expect(messages_for(result)).to be_empty
    end
  end

  describe 'Composition Sections Check - Recommended Sections' do # rubocop:disable Metrics/BlockLength
    let(:test) { find_test(:test_composition_recommended_sections) }
    let(:metadata) do
      {
        composition_sections: [
          {
            code: '11369-6',
            short: 'Patient Summary Immunizations Section',
            entries: [
              { profiles: ['Immunization|http://hl7.org/fhir/StructureDefinition/Immunization',
                           'DocumentReference|http://hl7.org/fhir/StructureDefinition/DocumentReference'] },
              { profiles: ['Immunization|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-immunization'] }
            ]
          },
          {
            code: '30954-2',
            short: 'Patient Summary Results Section',
            entries: [
              { profiles: ['Observation|http://hl7.org/fhir/StructureDefinition/Observation',
                           'DiagnosticReport|http://hl7.org/fhir/StructureDefinition/DiagnosticReport',
                           'DocumentReference|http://hl7.org/fhir/StructureDefinition/DocumentReference'] },
              { profiles: ['Observation|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-diagnosticresult-path'] }
            ]
          }
        ]
      }
    end

    let(:au_ps_warnings) do
      [
        have_attributes(type: 'warning',
                        message: "**Profile**: Immunization — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-immunization\n\n**Message**: No resources found"),
        have_attributes(type: 'warning',
                        message: "**Profile**: Observation — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-diagnosticresult-path\n\n**Message**: No resources found")
      ]
    end

    before { configure_test_class(test, metadata) }

    it 'passes when recommended sections are present' do
      bundle = build_bundle(sections: [
                              section_without_entries('11369-6'),
                              section_without_entries('30954-2')
                            ])
      result = run_test(scratch_with(bundle))
      messages = messages_for(result)

      expect(result.result).to eq('pass'), result.result_message
      expect(messages).to match_array(
        [
          have_attributes(type: 'info',
                          message: "Patient Summary Immunizations Section (11369-6)\n\nNo entries; no emptyReason."),
          have_attributes(type: 'info',
                          message: "Patient Summary Results Section (30954-2)\n\nNo entries; no emptyReason.")
        ] + au_ps_warnings
      )
    end

    it 'fails when a recommended section is absent from the composition' do
      bundle = build_bundle(sections: [section_without_entries('30954-2')])
      result = run_test(scratch_with(bundle))
      messages = messages_for(result)

      expect(result.result).to eq('fail')
      expect(messages).to match_array(
        [
          have_attributes(type: 'error',
                          message: "Patient Summary Immunizations Section (11369-6)\n\nNo composition section found for code: 11369-6"),
          have_attributes(type: 'info',
                          message: "Patient Summary Results Section (30954-2)\n\nNo entries; no emptyReason.")
        ] + au_ps_warnings
      )
    end

    it 'fails when a section entry references a resource of the wrong type' do
      condition_entry = FHIR::Bundle::Entry.new(
        fullUrl: 'urn:uuid:condition-1',
        resource: FHIR::Condition.new(resourceType: 'Condition')
      )
      bundle = build_bundle(
        sections: [
          section_with_entry('11369-6', 'urn:uuid:condition-1'),
          section_without_entries('30954-2')
        ],
        extra_entries: [condition_entry]
      )
      result = run_test(scratch_with(bundle))
      messages = messages_for(result)

      expect(result.result).to eq('fail')
      expect(messages).to match_array(
        [
          have_attributes(type: 'error',
                          message: "Patient Summary Immunizations Section (11369-6)\n\nentry[0]: **urn:uuid:condition-1** -> ❌ Invalid resource type"),
          have_attributes(type: 'info',
                          message: "Patient Summary Results Section (30954-2)\n\nNo entries; no emptyReason.")
        ] + au_ps_warnings
      )
    end
  end

  describe 'Composition Sections Check - Optional Sections' do # rubocop:disable Metrics/BlockLength
    let(:test) { find_test(:test_composition_optional_sections) }
    let(:metadata) do
      {
        composition_sections: [
          {
            code: '42348-3',
            short: 'Patient Summary Advance Directives Section',
            entries: [
              { profiles: ['Consent|http://hl7.org/fhir/StructureDefinition/Consent',
                           'DocumentReference|http://hl7.org/fhir/StructureDefinition/DocumentReference'] }
            ]
          }
        ]
      }
    end

    before { configure_test_class(test, metadata) }

    it 'passes when the optional section is present' do
      bundle = build_bundle(sections: [section_without_entries('42348-3')])
      result = run_test(scratch_with(bundle))
      messages = messages_for(result)

      expect(result.result).to eq('pass'), result.result_message
      expect(messages).to match_array([
                                        have_attributes(type: 'info',
                                                        message: "Patient Summary Advance Directives Section (42348-3)\n\nNo entries; no emptyReason.")
                                      ])
    end

    it 'fails when the optional section is absent from the composition' do
      bundle = build_bundle(sections: [])
      result = run_test(scratch_with(bundle))
      messages = messages_for(result)

      expect(result.result).to eq('fail')
      expect(messages).to match_array([
                                        have_attributes(type: 'error',
                                                        message: "Patient Summary Advance Directives Section (42348-3)\n\nNo composition section found for code: 42348-3")
                                      ])
    end

    it 'fails when an optional section entry references a resource of the wrong type' do
      observation_entry = FHIR::Bundle::Entry.new(
        fullUrl: 'urn:uuid:observation-1',
        resource: FHIR::Observation.new(resourceType: 'Observation', status: 'final',
                                        code: { coding: [{ code: '1234-5' }] })
      )
      bundle = build_bundle(
        sections: [section_with_entry('42348-3', 'urn:uuid:observation-1')],
        extra_entries: [observation_entry]
      )
      result = run_test(scratch_with(bundle))
      messages = messages_for(result)

      expect(result.result).to eq('fail')
      expect(messages).to match_array([
                                        have_attributes(type: 'error',
                                                        message: "Patient Summary Advance Directives Section (42348-3)\n\nentry[0]: **urn:uuid:observation-1** -> ❌ Invalid resource type")
                                      ])
    end
  end
end
# rubocop:enable Layout/LineLength
