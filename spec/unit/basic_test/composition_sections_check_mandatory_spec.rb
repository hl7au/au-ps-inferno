# frozen_string_literal: true

require_relative '../../support/basic_test/composition_sections_mandatory_fixture_spec_setup'

RSpec.describe AUPSTestKit::BasicTestCompositionSectionReadModule do
  include_context 'composition sections by metadata path base'

  describe 'Composition Sections Check - Mandatory Sections' do
    let(:test) { find_test(:test_composition_mandatory_sections) }
    let(:success_bundle_filename) { 'mandatory-success-bundle.json' }
    let(:error_bundle_filename) { 'mandatory-error-ms-bundle.json' }

    it 'passes when all mandatory elements are present and references are resolved correctly' do
      outcome = run_with_fixture_bundle(test, fixture_filename: success_bundle_filename)

      expect_pass(outcome)
    end

    it 'fails when any mandatory element is not populated or references are not resolved correctly' do
      outcome = run_with_fixture_bundle(test, fixture_filename: error_bundle_filename)

      expect_fail(outcome)
    end

    it 'returns a warning message when optional AllergyIntolerance Must Support elements are not populated' do
      outcome = run_with_fixture_bundle(test, fixture_filename: success_bundle_filename)

      expect_warning_message(
        outcome,
        msg(<<~MSG)
          At least one optional Must Support element is not populated in the Patient Summary Allergies and Intolerances Section (48765-2) section. Further testing with data containing the missing elements or clarification the system does not ever know a value for the element is required.

          **Profile**: AllergyIntolerance — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-allergyintolerance

          List of Must Support elements populated or missing

          ✅ Populated: clinicalStatus

          ⚠️ Missing: verificationStatus

          ⚠️ Missing: type

          ✅ Populated: code (M)

          ✅ Populated: patient (M)

          |- ✅ Populated: patient.reference (M)

          ✅ Populated: onsetDateTime

          ⚠️ Missing: note

          ✅ Populated: reaction

          |- ✅ Populated: reaction.manifestation (M)

          |- ✅ Populated: reaction.severity
        MSG
      )
    end

    it 'returns a warning message when mandatory elements are populated but optional elements are not' do
      outcome = run_with_fixture_bundle(test, fixture_filename: success_bundle_filename)

      expect_warning_message(
        outcome,
        msg(<<~MSG)
          At least one optional Must Support element is not populated in the Patient Summary Problems Section (11450-4) section. Further testing with data containing the missing elements or clarification the system does not ever know a value for the element is required.

          **Profile**: Condition — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition

          List of Must Support elements populated or missing

          ✅ Populated: clinicalStatus

          ⚠️ Missing: verificationStatus

          ✅ Populated: category (M)

          ⚠️ Missing: severity

          ✅ Populated: code (M)

          ✅ Populated: subject (M)

          |- ✅ Populated: subject.reference (M)

          ⚠️ Missing: onsetDateTime

          ⚠️ Missing: abatement[x]

          ⚠️ Missing: note
        MSG
      )
    end

    it 'returns a warning message when there is no resource in the section' do
      outcome = run_with_fixture_bundle(test, fixture_filename: error_bundle_filename)

      expect_warning_message(
        outcome,
        msg(<<~MSG)
          No resources found

          **Profile**: MedicationRequest — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationrequest
        MSG
      )
    end

    it 'returns an error message when any mandatory element is not populated' do
      outcome = run_with_fixture_bundle(test, fixture_filename: error_bundle_filename)

      expect_error_message(
        outcome,
        msg(<<~MSG)
          At least one mandatory Must Support element is not populated in the Patient Summary Problems Section (11450-4) section.

          **Profile**: Condition — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition

          List of Must Support elements populated or missing

          ✅ Populated: clinicalStatus

          ⚠️ Missing: verificationStatus

          ❌ Missing: category (M)

          ⚠️ Missing: severity

          ✅ Populated: code (M)

          ✅ Populated: subject (M)

          |- ✅ Populated: subject.reference (M)

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
        msg(<<~MSG)
          Patient Summary Problems Section (11450-4)

          entry[0]: **urn:uuid:310f1593-d610-4144-a6e8-1f823d955e0d** -> Condition (no meta.profile)
        MSG
      )
    end

    it 'returns an info message when reference is resolved with meta.profile' do
      outcome = run_with_fixture_bundle(test, fixture_filename: error_bundle_filename)

      expect_info_message(
        outcome,
        msg(<<~MSG)
          Patient Summary Allergies and Intolerances Section (48765-2)

          entry[0]: **urn:uuid:ad6fb7b7-c76f-441e-88a5-9051e795db26** -> AllergyIntolerance (meta.profile: http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-allergyintolerance)

          entry[1]: **urn:uuid:06ba95f5-345b-412d-aa66-99e354470015** -> AllergyIntolerance (no meta.profile)

          entry[2]: **urn:uuid:d24db2d5-3400-4158-892c-d018acdeba09** -> AllergyIntolerance (no meta.profile)
        MSG
      )
    end

    it 'returns an error message when reference is resolved but resource type is not permitted' do
      outcome = run_with_fixture_bundle(test, fixture_filename: error_bundle_filename)

      expect_error_message(
        outcome,
        msg(<<~MSG)
          Patient Summary Medication Summary Section (10160-0)

          entry[0]: **urn:uuid:aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee** -> ❌ Invalid resource type: Device
        MSG
      )
    end
  end
end
