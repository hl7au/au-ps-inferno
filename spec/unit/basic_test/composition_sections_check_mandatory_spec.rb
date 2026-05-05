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
    let(:metadata) { CompositionSectionsMetadata::MANDATORY_SECTIONS }

    before { configure_test_class(test, metadata) }

    it 'passes when all mandatory sections are present' do
      outcome = run_with_sections(
        test,
        sections: [
          section_without_entries(CompositionSectionsConstants::PROBLEMS_SECTION[:code]),
          section_without_entries(CompositionSectionsConstants::ALLERGIES_SECTION[:code]),
          section_without_entries(CompositionSectionsConstants::MEDICATION_SECTION[:code])
        ]
      )

      expect_pass(outcome)
      expect_info_message(outcome, "Patient Summary Problems Section (11450-4)\n\nNo entries; no emptyReason.")
      expect_info_message(outcome, "Patient Summary Allergies and Intolerances Section (48765-2)\n\nNo entries; no emptyReason.")
      expect_info_message(outcome, "Patient Summary Medication Summary Section (10160-0)\n\nNo entries; no emptyReason.")
      expect_warning_message(outcome, "**Profile**: AllergyIntolerance — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-allergyintolerance\n\n**Message**: No resources found")
      expect_warning_message(outcome, "**Profile**: MedicationStatement — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement\n\n**Message**: No resources found")
      expect_warning_message(outcome, "**Profile**: MedicationRequest — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationrequest\n\n**Message**: No resources found")
    end

    it 'passes when a section has an emptyReason instead of entries' do
      outcome = run_with_sections(
        test,
        sections: [
          section_with_empty_reason(CompositionSectionsConstants::PROBLEMS_SECTION[:code], display: 'Withheld', reason_code: 'withheld'),
          section_without_entries(CompositionSectionsConstants::ALLERGIES_SECTION[:code]),
          section_without_entries(CompositionSectionsConstants::MEDICATION_SECTION[:code])
        ]
      )

      expect_pass(outcome)
      expect_info_message(outcome, "Patient Summary Problems Section (11450-4)\n\nemptyReason: Withheld (withheld)")
      expect_info_message(outcome, "Patient Summary Allergies and Intolerances Section (48765-2)\n\nNo entries; no emptyReason.")
      expect_info_message(outcome, "Patient Summary Medication Summary Section (10160-0)\n\nNo entries; no emptyReason.")
      expect_warning_message(outcome, "**Profile**: AllergyIntolerance — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-allergyintolerance\n\n**Message**: No resources found")
      expect_warning_message(outcome, "**Profile**: MedicationStatement — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement\n\n**Message**: No resources found")
      expect_warning_message(outcome, "**Profile**: MedicationRequest — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationrequest\n\n**Message**: No resources found")
    end

    it 'passes when all mandatory sections are present (version 2)' do
      # NOTE: Experimental implementation of expect_info_messages and expect_warning_messages.
      # We should discuss if we want to keep this.
      outcome = run_with_sections(
        test,
        sections: [
          section_without_entries(CompositionSectionsConstants::PROBLEMS_SECTION[:code]),
          section_without_entries(CompositionSectionsConstants::ALLERGIES_SECTION[:code]),
          section_without_entries(CompositionSectionsConstants::MEDICATION_SECTION[:code])
        ]
      )
      expected_info_messages = [
        "Patient Summary Problems Section (11450-4)\n\nNo entries; no emptyReason.",
        "Patient Summary Allergies and Intolerances Section (48765-2)\n\nNo entries; no emptyReason.",
        "Patient Summary Medication Summary Section (10160-0)\n\nNo entries; no emptyReason."
      ]
      expected_warning_messages = [
        "**Profile**: AllergyIntolerance — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-allergyintolerance\n\n**Message**: No resources found",
        "**Profile**: MedicationStatement — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement\n\n**Message**: No resources found",
        "**Profile**: MedicationRequest — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationrequest\n\n**Message**: No resources found"
      ]

      expect_pass(outcome)
      expect_info_messages(outcome, expected_info_messages)
      expect_warning_messages(outcome, expected_warning_messages)
    end

    it 'fails when a mandatory section is absent from the composition' do
      outcome = run_with_sections(
        test,
        sections: [
          section_without_entries(CompositionSectionsConstants::ALLERGIES_SECTION[:code]),
          section_without_entries(CompositionSectionsConstants::MEDICATION_SECTION[:code])
        ]
      )

      expect_fail(outcome)
      expect_error_message(outcome, "Patient Summary Problems Section (11450-4)\n\nNo composition section found for code: 11450-4")
      expect_info_message(outcome, "Patient Summary Allergies and Intolerances Section (48765-2)\n\nNo entries; no emptyReason.")
      expect_info_message(outcome, "Patient Summary Medication Summary Section (10160-0)\n\nNo entries; no emptyReason.")
      expect_warning_message(outcome, "**Profile**: AllergyIntolerance — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-allergyintolerance\n\n**Message**: No resources found")
      expect_warning_message(outcome, "**Profile**: MedicationStatement — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement\n\n**Message**: No resources found")
      expect_warning_message(outcome, "**Profile**: MedicationRequest — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationrequest\n\n**Message**: No resources found")
    end

    it 'fails when a section entry reference does not resolve' do
      outcome = run_with_sections(
        test,
        sections: [
          section_with_entry(CompositionSectionsConstants::PROBLEMS_SECTION[:code], 'urn:uuid:missing-condition-1'),
          section_without_entries(CompositionSectionsConstants::ALLERGIES_SECTION[:code]),
          section_without_entries(CompositionSectionsConstants::MEDICATION_SECTION[:code])
        ]
      )

      expect_fail(outcome)
      expect_error_message(outcome, "Patient Summary Problems Section (11450-4)\n\n**urn:uuid:missing-condition-1** -> ❌ Reference does not resolve")
      expect_info_message(outcome, "Patient Summary Allergies and Intolerances Section (48765-2)\n\nNo entries; no emptyReason.")
      expect_info_message(outcome, "Patient Summary Medication Summary Section (10160-0)\n\nNo entries; no emptyReason.")
      expect_warning_message(outcome, "**Profile**: Condition — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition\n\n**Message**: No resources found")
      expect_warning_message(outcome, "**Profile**: AllergyIntolerance — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-allergyintolerance\n\n**Message**: No resources found")
      expect_warning_message(outcome, "**Profile**: MedicationStatement — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement\n\n**Message**: No resources found")
      expect_warning_message(outcome, "**Profile**: MedicationRequest — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationrequest\n\n**Message**: No resources found")
    end

    it 'passes when a section entry reference resolves with no meta.profile' do
      outcome = run_with_sections(
        test,
        sections: [
          section_with_entry(CompositionSectionsConstants::PROBLEMS_SECTION[:code], 'urn:uuid:condition-1'),
          section_without_entries(CompositionSectionsConstants::ALLERGIES_SECTION[:code]),
          section_without_entries(CompositionSectionsConstants::MEDICATION_SECTION[:code])
        ],
        extra_entries: [condition_entry]
      )

      expect_pass(outcome)
      expect_info_message(outcome, "Patient Summary Problems Section (11450-4)\n\nentry[0]: **urn:uuid:condition-1** -> Condition (no meta.profile)")
    end

    it 'passes when a section entry reference resolves with meta.profile' do
      outcome = run_with_sections(
        test,
        sections: [
          section_with_entry(CompositionSectionsConstants::PROBLEMS_SECTION[:code], 'urn:uuid:condition-1'),
          section_without_entries(CompositionSectionsConstants::ALLERGIES_SECTION[:code]),
          section_without_entries(CompositionSectionsConstants::MEDICATION_SECTION[:code])
        ],
        extra_entries: [condition_entry(meta_profile: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition')]
      )

      expect_pass(outcome)
      expect_info_message(outcome, "Patient Summary Problems Section (11450-4)\n\nentry[0]: **urn:uuid:condition-1** -> Condition (meta.profile: http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition)")
    end

    it 'fails when a section entry references a resource of the wrong type' do
      outcome = run_with_sections(
        test,
        sections: [
          section_with_entry(CompositionSectionsConstants::PROBLEMS_SECTION[:code], 'urn:uuid:observation-1'),
          section_without_entries(CompositionSectionsConstants::ALLERGIES_SECTION[:code]),
          section_without_entries(CompositionSectionsConstants::MEDICATION_SECTION[:code])
        ],
        extra_entries: [observation_entry]
      )

      expect_fail(outcome)
      expect_error_message(outcome, "Patient Summary Problems Section (11450-4)\n\nentry[0]: **urn:uuid:observation-1** -> ❌ Invalid resource type")
      expect_info_message(outcome, "Patient Summary Allergies and Intolerances Section (48765-2)\n\nNo entries; no emptyReason.")
      expect_info_message(outcome, "Patient Summary Medication Summary Section (10160-0)\n\nNo entries; no emptyReason.")
      expect_warning_message(outcome, "**Profile**: Condition — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition\n\n**Message**: No resources found")
      expect_warning_message(outcome, "**Profile**: AllergyIntolerance — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-allergyintolerance\n\n**Message**: No resources found")
      expect_warning_message(outcome, "**Profile**: MedicationStatement — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement\n\n**Message**: No resources found")
      expect_warning_message(outcome, "**Profile**: MedicationRequest — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationrequest\n\n**Message**: No resources found")
    end

    it 'fails when section entries mix resolved and unresolved references' do
      outcome = run_with_sections(
        test,
        sections: [
          section_with_entries(CompositionSectionsConstants::PROBLEMS_SECTION[:code], 'urn:uuid:condition-1', 'urn:uuid:missing-2'),
          section_without_entries(CompositionSectionsConstants::ALLERGIES_SECTION[:code]),
          section_without_entries(CompositionSectionsConstants::MEDICATION_SECTION[:code])
        ],
        extra_entries: [condition_entry]
      )

      expect_fail(outcome)
      expect_error_message(outcome, "Patient Summary Problems Section (11450-4)\n\nentry[0]: **urn:uuid:condition-1** -> Condition (no meta.profile)")
      expect_error_message(outcome, '**urn:uuid:missing-2** -> ❌ Reference does not resolve')
      expect_info_message(outcome, "Patient Summary Allergies and Intolerances Section (48765-2)\n\nNo entries; no emptyReason.")
      expect_info_message(outcome, "Patient Summary Medication Summary Section (10160-0)\n\nNo entries; no emptyReason.")
      expect_warning_message(outcome, "**Profile**: AllergyIntolerance — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-allergyintolerance\n\n**Message**: No resources found")
      expect_warning_message(outcome, "**Profile**: MedicationStatement — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement\n\n**Message**: No resources found")
    end

    it 'fails when all mandatory sections are absent from the composition' do
      outcome = run_with_sections(test, sections: [])

      expect_fail(outcome)
      expect_error_message(outcome, "Patient Summary Problems Section (11450-4)\n\nNo composition section found for code: 11450-4")
      expect_error_message(outcome, "Patient Summary Allergies and Intolerances Section (48765-2)\n\nNo composition section found for code: 48765-2")
      expect_error_message(outcome, "Patient Summary Medication Summary Section (10160-0)\n\nNo composition section found for code: 10160-0")
      expect_warning_message(outcome, "**Profile**: Condition — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition\n\n**Message**: No resources found")
      expect_warning_message(outcome, "**Profile**: AllergyIntolerance — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-allergyintolerance\n\n**Message**: No resources found")
      expect_warning_message(outcome, "**Profile**: MedicationStatement — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement\n\n**Message**: No resources found")
      expect_warning_message(outcome, "**Profile**: MedicationRequest — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationrequest\n\n**Message**: No resources found")
    end
  end
end
# rubocop:enable Layout/LineLength
