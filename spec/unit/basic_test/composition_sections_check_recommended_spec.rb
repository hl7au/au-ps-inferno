# frozen_string_literal: true

require_relative '../../support/basic_test/composition_sections_mandatory_fixture_spec_setup'

RSpec.describe AUPSTestKit::BasicTestCompositionSectionReadModule do
  include_context 'composition sections by metadata path base'

  describe 'Composition Sections Check - Recommended Sections' do
    let(:test) { find_test(:test_composition_recommended_sections) }
    let(:success_bundle_filename) { 'recommended-success-bundle.json' }
    let(:error_bundle_filename) { 'recommended-error-ms-bundle.json' }

    it 'passes when all mandatory elements are present and references are resolved correctly' do
      outcome = run_with_fixture_bundle(test, fixture_filename: success_bundle_filename)

      expect_pass(outcome)
    end

    it 'passes even when the error bundle has MS or reference issues (recommended sections do not fail the runnable)' do
      outcome = run_with_fixture_bundle(test, fixture_filename: error_bundle_filename)

      expect_pass(outcome)
    end

    it 'returns an info message when all mandatory and optional elements are populated' do
      outcome = run_with_fixture_bundle(test, fixture_filename: success_bundle_filename)

      expect_info_message(
        outcome,
        <<~MSG.chomp
          All Must Support elements are populated in the Patient Summary Immunizations Section (11369-6) section.

          **Profile**: Immunization — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-immunization

          List of Must Support elements populated or missing

          ✅ Populated: status (M)

          ✅ Populated: vaccineCode (M)

          ✅ Populated: patient (M)

          |- ✅ Populated: patient.reference (M)

          ✅ Populated: occurrenceDateTime

          ✅ Populated: primarySource

          ✅ Populated: lotNumber

          ✅ Populated: note
        MSG
      )
    end

    it 'returns a warning message when mandatory elements are populated but optional elements are not' do
      outcome = run_with_fixture_bundle(test, fixture_filename: success_bundle_filename)

      expect_warning_message(
        outcome,
        <<~MSG.chomp
          At least one optional Must Support element is not populated in the Patient Summary Results Section (30954-2) section. Further testing with data containing the missing elements or clarification the system does not ever know a value for the element is required.

          **Profile**: Observation — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-diagnosticresult-path

          List of Must Support elements populated or missing

          ✅ Populated: status (M)

          ✅ Populated: category (M)

          ✅ Populated: code (M)

          ✅ Populated: subject (M)

          |- ✅ Populated: subject.reference (M)

          ✅ Populated: effectiveDateTime

          ✅ Populated: performer (M)

          ⚠️ Missing: value[x]

          ⚠️ Missing: dataAbsentReason

          ⚠️ Missing: interpretation

          ⚠️ Missing: specimen

          ⚠️ Missing: referenceRange

          ⚠️ Missing: hasMember

          ✅ Populated: component

          |- ✅ Populated: component.code (M)

          |- ✅ Populated: component.value[x]

          |- ⚠️ Missing: component.dataAbsentReason
        MSG
      )
    end

    it 'returns a warning message when there is no resource in the section' do
      outcome = run_with_fixture_bundle(test, fixture_filename: success_bundle_filename)

      expect_warning_message(
        outcome,
        <<~MSG.chomp
          No resources found

          **Profile**: Procedure — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-procedure
        MSG
      )
    end

    it 'returns an error message when any mandatory element is not populated' do
      outcome = run_with_fixture_bundle(test, fixture_filename: error_bundle_filename)

      expect_error_message(
        outcome,
        <<~MSG.chomp
          At least one mandatory Must Support element is not populated in the Patient Summary Immunizations Section (11369-6) section.

          **Profile**: Immunization — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-immunization

          List of Must Support elements populated or missing

          ✅ Populated: status (M)

          ❌ Missing: vaccineCode (M)

          ✅ Populated: patient (M)

          |- ✅ Populated: patient.reference (M)

          ✅ Populated: occurrenceDateTime

          ✅ Populated: primarySource

          ✅ Populated: lotNumber

          ✅ Populated: note
        MSG
      )
    end

    it 'returns an info message when reference is resolved without meta.profile' do
      outcome = run_with_fixture_bundle(test, fixture_filename: success_bundle_filename)

      expect_info_message(
        outcome,
        <<~MSG.chomp
          Patient Summary Immunizations Section (11369-6)

          entry[0]: **urn:uuid:cccccccc-0001-0000-0000-000000000006** -> Immunization (no meta.profile)
        MSG
      )
    end

    it 'returns an info message when reference is resolved with meta.profile' do
      outcome = run_with_fixture_bundle(test, fixture_filename: error_bundle_filename)

      expect_info_message(
        outcome,
        <<~MSG.chomp
          Patient Summary Immunizations Section (11369-6)

          entry[0]: **urn:uuid:cccccccc-0002-0000-0000-000000000006** -> Immunization (meta.profile: http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-immunization)

          entry[1]: **urn:uuid:cccccccc-0002-0000-0000-000000000007** -> Immunization (no meta.profile)

          entry[2]: **urn:uuid:cccccccc-0002-0000-0000-000000000008** -> Immunization (no meta.profile)
        MSG
      )
    end

    it 'returns a warning message when reference is resolved but resource type is not permitted' do
      outcome = run_with_fixture_bundle(test, fixture_filename: error_bundle_filename)

      expect_warning_message(
        outcome,
        <<~MSG.chomp
          Patient Summary Results Section (30954-2)

          entry[0]: **urn:uuid:cccccccc-0002-0000-0000-000000000009** -> ❌ Invalid resource type: AllergyIntolerance
        MSG
      )
    end
  end
end
