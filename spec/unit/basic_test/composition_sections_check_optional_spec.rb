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
    let(:metadata) { CompositionSectionsMetadata::OPTIONAL_SECTIONS }

    before { configure_test_class(test, metadata) }

    it 'passes when the optional section is present' do
      outcome = run_with_sections(test, sections: [section_without_entries(CompositionSectionsConstants::ADVANCE_DIRECTIVES_SECTION[:code])])

      expect_pass(outcome)
      expect_info_message(outcome, "Patient Summary Advance Directives Section (42348-3)\n\nNo entries; no emptyReason.")
    end

    it 'fails when the optional section is absent from the composition' do
      outcome = run_with_sections(test, sections: [])

      expect_fail(outcome)
      expect_error_message(outcome, "Patient Summary Advance Directives Section (42348-3)\n\nNo composition section found for code: 42348-3")
    end

    it 'fails when an optional section entry references a resource of the wrong type' do
      outcome = run_with_sections(
        test,
        sections: [section_with_entry(CompositionSectionsConstants::ADVANCE_DIRECTIVES_SECTION[:code], 'urn:uuid:observation-1')],
        extra_entries: [observation_entry]
      )

      expect_fail(outcome)
      expect_error_message(outcome, "Patient Summary Advance Directives Section (42348-3)\n\nentry[0]: **urn:uuid:observation-1** -> ❌ Invalid resource type")
    end

    it 'skips when no bundle is provided in scratch' do
      result = run_test({})

      expect(result.result).to eq('skip')
      expect(messages_for(result)).to be_empty
    end
  end
end
# rubocop:enable Layout/LineLength
