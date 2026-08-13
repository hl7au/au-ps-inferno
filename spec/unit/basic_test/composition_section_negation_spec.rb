# frozen_string_literal: true

require_relative '../../support/basic_test/composition_section_negation_spec_setup'

RSpec.describe AUPSTestKit::BasicTestCompositionSectionNegationModule do
  include_context 'composition section negation check setup'

  describe 'warning against emptyReason=nilknown' do
    it 'warns when a mandatory section uses emptyReason=nilknown instead of an explicit negation entry' do
      outcome = run_with_fixture_bundle(test, fixture_filename: 'mandatory-nilknown-warning-bundle.json')

      expect_pass(outcome)
      expect_warning_message(
        outcome,
        msg(<<~MSG)
          Patient Summary Allergies and Intolerances Section (48765-2) uses emptyReason = nilknown ('Nil Known'). AU PS prefers an explicit negation code on the section entry instead of Composition.section.emptyReason, e.g. AllergyIntolerance.code = 716186003 |No known allergy|.
        MSG
      )
    end

    it 'does not warn when sections are populated with entries as normal' do
      outcome = run_with_fixture_bundle(test, fixture_filename: 'mandatory-success-bundle.json')

      expect_pass(outcome)
      expect(outcome[:messages]).to be_empty
    end

    it 'does not warn when emptyReason uses a legitimate code such as unavailable' do
      outcome = run_with_fixture_bundle(test, fixture_filename: 'mandatory-unavailable-empty-reason-bundle.json')

      expect_pass(outcome)
      expect(outcome[:messages]).to be_empty
    end

    it 'does not warn when a section uses the preferred explicit negation code on its entry' do
      outcome = run_with_fixture_bundle(test, fixture_filename: 'mandatory-negation-code-bundle.json')

      expect_pass(outcome)
      expect(outcome[:messages]).to be_empty
    end
  end
end
