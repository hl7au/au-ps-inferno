# frozen_string_literal: true

require 'fhir_models'

require_relative '../../support/basic_test/composition_sections_check_support'
require File.join(Gem::Specification.find_by_name('inferno_core').full_gem_path, 'spec/runnable_context')

# rubocop:disable Layout/LineLength
RSpec.describe AUPSTestKit::BasicTestCompositionSectionReadModule do # rubocop:disable Metrics/BlockLength
  include_context 'when testing a runnable'
  include_context 'composition sections check setup'

  describe 'Composition Sections Check - Optional Sections' do # rubocop:disable Metrics/BlockLength
    let(:test) { find_test(:test_composition_optional_sections) }
    let(:metadata) do
      {
        composition_sections: [
          {
            code: CompositionSectionsConstants::ADVANCE_DIRECTIVES_SECTION[:code],
            short: CompositionSectionsConstants::ADVANCE_DIRECTIVES_SECTION[:title],
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
      outcome = run_with_sections(test, sections: [section_without_entries(CompositionSectionsConstants::ADVANCE_DIRECTIVES_SECTION[:code])])
      expect_result_and_messages(
        result: outcome[:result],
        messages: outcome[:messages],
        status: 'pass',
        expected_messages: [
          { type: 'info',
            text: "#{CompositionSectionsConstants::ADVANCE_DIRECTIVES_SECTION[:title]} (#{CompositionSectionsConstants::ADVANCE_DIRECTIVES_SECTION[:code]})\n\nNo entries; no emptyReason." }
        ]
      )
    end

    it 'fails when the optional section is absent from the composition' do
      outcome = run_with_sections(test, sections: [])
      expect_result_and_messages(
        result: outcome[:result],
        messages: outcome[:messages],
        status: 'fail',
        expected_messages: [
          { type: 'error',
            text: "#{CompositionSectionsConstants::ADVANCE_DIRECTIVES_SECTION[:title]} (#{CompositionSectionsConstants::ADVANCE_DIRECTIVES_SECTION[:code]})\n\nNo composition section found for code: #{CompositionSectionsConstants::ADVANCE_DIRECTIVES_SECTION[:code]}" }
        ]
      )
    end

    it 'fails when an optional section entry references a resource of the wrong type' do
      observation_entry = FHIR::Bundle::Entry.new(
        fullUrl: 'urn:uuid:observation-1',
        resource: FHIR::Observation.new(resourceType: 'Observation', status: 'final',
                                        code: { coding: [{ code: '1234-5' }] })
      )
      outcome = run_with_sections(
        test,
        sections: [section_with_entry(CompositionSectionsConstants::ADVANCE_DIRECTIVES_SECTION[:code], 'urn:uuid:observation-1')],
        extra_entries: [observation_entry]
      )
      expect_result_and_messages(
        result: outcome[:result],
        messages: outcome[:messages],
        status: 'fail',
        expected_messages: [
          { type: 'error',
            text: "#{CompositionSectionsConstants::ADVANCE_DIRECTIVES_SECTION[:title]} (#{CompositionSectionsConstants::ADVANCE_DIRECTIVES_SECTION[:code]})\n\nentry[0]: **urn:uuid:observation-1** -> ❌ Invalid resource type" }
        ]
      )
    end

    it 'skips when no bundle is provided in scratch' do
      result = run_test({})

      expect(result.result).to eq('skip')
      expect(messages_for(result)).to be_empty
    end
  end
end
# rubocop:enable Layout/LineLength
