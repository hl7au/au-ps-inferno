# frozen_string_literal: true

require 'fhir_models'

require_relative '../../support/basic_test/composition_sections_check_support'
require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

# rubocop:disable Layout/LineLength
RSpec.describe AUPSTestKit::BasicTestCompositionSectionReadModule do # rubocop:disable Metrics/BlockLength
  include_context 'when testing a runnable'
  include_context 'composition sections check setup'

  describe 'Composition Sections Check - Recommended Sections' do # rubocop:disable Metrics/BlockLength
    let(:test) { find_test(:test_composition_recommended_sections) }
    let(:metadata) do
      {
        composition_sections: [
          {
            code: CompositionSectionsConstants::IMMUNIZATIONS_SECTION[:code],
            short: CompositionSectionsConstants::IMMUNIZATIONS_SECTION[:title],
            entries: [
              { profiles: ['Immunization|http://hl7.org/fhir/StructureDefinition/Immunization',
                           'DocumentReference|http://hl7.org/fhir/StructureDefinition/DocumentReference'] },
              { profiles: ['Immunization|http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-immunization'] }
            ]
          },
          {
            code: CompositionSectionsConstants::RESULTS_SECTION[:code],
            short: CompositionSectionsConstants::RESULTS_SECTION[:title],
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

    before { configure_test_class(test, metadata) }

    it 'passes when recommended sections are present' do
      outcome = run_with_sections(
        test,
        sections: [
          section_without_entries(CompositionSectionsConstants::IMMUNIZATIONS_SECTION[:code]),
          section_without_entries(CompositionSectionsConstants::RESULTS_SECTION[:code])
        ]
      )

      expect_pass(outcome)
      expect_info_message(outcome, "Patient Summary Immunizations Section (11369-6)\n\nNo entries; no emptyReason.")
      expect_info_message(outcome, "Patient Summary Results Section (30954-2)\n\nNo entries; no emptyReason.")
      expect_warning_message(outcome, "**Profile**: Immunization — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-immunization\n\n**Message**: No resources found")
      expect_warning_message(outcome, "**Profile**: Observation — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-diagnosticresult-path\n\n**Message**: No resources found")
    end

    it 'fails when a recommended section is absent from the composition' do
      outcome = run_with_sections(test, sections: [section_without_entries(CompositionSectionsConstants::RESULTS_SECTION[:code])])

      expect_fail(outcome)
      expect_error_message(outcome, "Patient Summary Immunizations Section (11369-6)\n\nNo composition section found for code: 11369-6")
      expect_info_message(outcome, "Patient Summary Results Section (30954-2)\n\nNo entries; no emptyReason.")
      expect_warning_message(outcome, "**Profile**: Immunization — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-immunization\n\n**Message**: No resources found")
      expect_warning_message(outcome, "**Profile**: Observation — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-diagnosticresult-path\n\n**Message**: No resources found")
    end

    it 'fails when a section entry references a resource of the wrong type' do
      outcome = run_with_sections(
        test,
        sections: [
          section_with_entry(CompositionSectionsConstants::IMMUNIZATIONS_SECTION[:code], 'urn:uuid:condition-1'),
          section_without_entries(CompositionSectionsConstants::RESULTS_SECTION[:code])
        ],
        extra_entries: [condition_entry]
      )

      expect_fail(outcome)
      expect_error_message(outcome, "Patient Summary Immunizations Section (11369-6)\n\nentry[0]: **urn:uuid:condition-1** -> ❌ Invalid resource type")
      expect_info_message(outcome, "Patient Summary Results Section (30954-2)\n\nNo entries; no emptyReason.")
      expect_warning_message(outcome, "**Profile**: Immunization — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-immunization\n\n**Message**: No resources found")
      expect_warning_message(outcome, "**Profile**: Observation — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-diagnosticresult-path\n\n**Message**: No resources found")
    end

    it 'skips when no bundle is provided in scratch' do
      result = run_test({})

      expect(result.result).to eq('skip')
      expect(messages_for(result)).to be_empty
    end
  end
end
# rubocop:enable Layout/LineLength
