# frozen_string_literal: true

require_relative '../../support/basic_test/composition_sections_mandatory_fixture_spec_setup'

RSpec.describe AUPSTestKit::BasicTestCompositionSectionReadModule do
  include_context 'composition sections by metadata path base'

  describe 'Composition Sections Check - Optional Sections' do
    let(:test) { find_test(:test_composition_optional_sections) }
    let(:success_bundle_filename) { 'optional-success-bundle.json' }
    let(:error_bundle_filename) { 'optional-error-ms-bundle.json' }

    it 'passes when all mandatory elements are present and references are resolved correctly' do
      outcome = run_with_fixture_bundle(test, fixture_filename: success_bundle_filename)

      expect_pass(outcome)
    end

    it 'fails when any mandatory element is not populated or references are not resolved correctly' do
      outcome = run_with_fixture_bundle(test, fixture_filename: error_bundle_filename)

      expect_fail(outcome)
    end

    it 'returns an info message when all mandatory and optional elements are populated' do
      outcome = run_with_fixture_bundle(test, fixture_filename: success_bundle_filename)

      expect_info_message(
        outcome,
        <<~MSG.chomp
          **Profile**: Condition — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition

          **Message**: All Must Support elements are populated.

          List of Must Support elements populated or missing

          ✅ Populated: clinicalStatus

          ✅ Populated: verificationStatus

          ✅ Populated: category (M)

          ✅ Populated: severity

          ✅ Populated: code (M)

          ✅ Populated: subject (M)

          ✅ Populated: subject.reference (M)

          ✅ Populated: onsetDateTime

          ✅ Populated: abatement[x]

          ✅ Populated: note
        MSG
      )
    end

    it 'returns a warning message when there is no resource in the section' do
      outcome = run_with_fixture_bundle(test, fixture_filename: success_bundle_filename)

      expect_warning_message(
        outcome,
        <<~MSG.chomp
          **Profile**: Observation — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-smokingstatus

          **Message**: No resources found
        MSG
      )
    end

    it 'returns an error message when any mandatory element is not populated' do
      outcome = run_with_fixture_bundle(test, fixture_filename: error_bundle_filename)

      expect_error_message(
        outcome,
        <<~MSG.chomp
          **Profile**: Condition — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition

          **Message**: At least one mandatory Must Support elements is not populated.

          List of Must Support elements populated or missing

          ✅ Populated: clinicalStatus

          ✅ Populated: verificationStatus

          ❌ Missing: category (M)

          ⚠️ Missing: severity

          ✅ Populated: code (M)

          ✅ Populated: subject (M)

          ✅ Populated: subject.reference (M)

          ⚠️ Missing: onsetDateTime

          ⚠️ Missing: abatement[x]

          ⚠️ Missing: note
        MSG
      )
    end

    it 'returns an info message when reference is resolved without meta.profile' do
      outcome = run_with_fixture_bundle(test, fixture_filename: success_bundle_filename)

      expect_info_message(
        outcome,
        <<~MSG.chomp
          Patient Summary Functional Status Section (47420-5)

          entry[0]: **urn:uuid:cccccccc-0003-0000-0000-000000000006** -> Condition (no meta.profile)
        MSG
      )
    end

    it 'returns an info message when reference is resolved with meta.profile' do
      outcome = run_with_fixture_bundle(test, fixture_filename: error_bundle_filename)

      expect_info_message(
        outcome,
        <<~MSG.chomp
          Patient Summary Functional Status Section (47420-5)

          entry[0]: **urn:uuid:cccccccc-0004-0000-0000-000000000007** -> Condition (meta.profile: http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition)
        MSG
      )
    end

    it 'returns an info message when reference is resolved without meta.profile for a different section' do
      outcome = run_with_fixture_bundle(test, fixture_filename: error_bundle_filename)

      expect_info_message(
        outcome,
        <<~MSG.chomp
          Patient Summary Advance Directives Section (42348-3)

          entry[0]: **urn:uuid:cccccccc-0004-0000-0000-000000000006** -> Consent (no meta.profile)
        MSG
      )
    end

    it 'returns an error message when reference is resolved but resource type is not permitted' do
      outcome = run_with_fixture_bundle(test, fixture_filename: error_bundle_filename)

      expect_error_message(
        outcome,
        <<~MSG.chomp
          Patient Summary Social History Section (29762-2)

          entry[0]: **urn:uuid:cccccccc-0004-0000-0000-000000000008** -> ❌ Invalid resource type
        MSG
      )
    end
  end
end
