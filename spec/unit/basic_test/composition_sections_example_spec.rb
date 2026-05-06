# frozen_string_literal: true

require_relative '../../support/basic_test/composition_sections_mandatory_fixture_spec_setup'

SUCCESS_BUNDLE_FILENAME = 'mandatory-success-bundle.json'
ERROR_MS_BUNDLE_FILENAME = 'mandatory-error-ms-bundle.json'
METADATA_FILENAME = 'metadata.yaml'

RSpec.describe AUPSTestKit::BasicTestCompositionSectionReadModule do
  include_context 'mandatory composition sections fixture by metadata path'

  describe 'Example Mandatory Fixture Spec' do
    it 'It should pass when all mandatory elements are present and references are resolved correctly' do
      outcome = run_with_fixture_bundle_for(
        test_method: :test_composition_mandatory_sections,
        fixture_filename: SUCCESS_BUNDLE_FILENAME,
        metadata_fixture_filename: METADATA_FILENAME
      )

      expect_pass(outcome)
    end

    it 'It should fail when any mandatory element is not populated or references are not resolved correctly' do
      outcome = run_with_fixture_bundle_for(
        test_method: :test_composition_mandatory_sections,
        fixture_filename: ERROR_MS_BUNDLE_FILENAME,
        metadata_fixture_filename: METADATA_FILENAME
      )

      expect_fail(outcome)
    end

    it 'It should return info message when all mandatory and optional elements are populated' do
      outcome = run_with_fixture_bundle_for(
        test_method: :test_composition_mandatory_sections,
        fixture_filename: SUCCESS_BUNDLE_FILENAME,
        metadata_fixture_filename: METADATA_FILENAME
      )
      expect_info_message(
        outcome,
        <<~MSG.chomp
          **Profile**: AllergyIntolerance — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-allergyintolerance

          **Message**: All Must Support elements are populated.

          List of Must Support elements populated or missing

          ✅ Populated: clinicalStatus

          ✅ Populated: verificationStatus

          ✅ Populated: type

          ✅ Populated: code (M)

          ✅ Populated: patient (M)

          ✅ Populated: patient.reference (M)

          ✅ Populated: onsetDateTime

          ✅ Populated: note

          ✅ Populated: reaction

          ✅ Populated: reaction.manifestation (M)

          ✅ Populated: reaction.severity
        MSG
      )
    end
    it 'It should return warning message with details when mandatory elements are populated but optional elements are not' do
      outcome = run_with_fixture_bundle_for(
        test_method: :test_composition_mandatory_sections,
        fixture_filename: SUCCESS_BUNDLE_FILENAME,
        metadata_fixture_filename: METADATA_FILENAME
      )

      expect_warning_message(
        outcome,
        <<~MSG.chomp
          **Profile**: Condition — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition

          **Message**: At least one optional Must Support element is not populated. Further testing with data containing the missing elements or clarification the system does not ever know a value for the element is required.

          List of Must Support elements populated or missing

          ✅ Populated: clinicalStatus

          ⚠️ Missing: verificationStatus

          ✅ Populated: category (M)

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

    it 'It should return warning message with details when there is no resource in the section' do
      outcome = run_with_fixture_bundle_for(
        test_method: :test_composition_mandatory_sections,
        fixture_filename: ERROR_MS_BUNDLE_FILENAME,
        metadata_fixture_filename: METADATA_FILENAME
      )

      expect_warning_message(
        outcome,
        <<~MSG.chomp
          **Profile**: MedicationRequest — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationrequest

          **Message**: No resources found
        MSG
      )
    end

    it 'It should return error message with details when any mandatory element is not populated' do
      outcome = run_with_fixture_bundle_for(
        test_method: :test_composition_mandatory_sections,
        fixture_filename: ERROR_MS_BUNDLE_FILENAME,
        metadata_fixture_filename: METADATA_FILENAME
      )

      expect_error_message(
        outcome,
        <<~MSG.chomp
          **Profile**: Condition — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition

          **Message**: At least one mandatory Must Support elements is not populated.

          List of Must Support elements populated or missing

          ✅ Populated: clinicalStatus

          ⚠️ Missing: verificationStatus

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

    it 'It should return info message with details when reference is resolved without meta.profile' do
      outcome = run_with_fixture_bundle_for(
        test_method: :test_composition_mandatory_sections,
        fixture_filename: SUCCESS_BUNDLE_FILENAME,
        metadata_fixture_filename: METADATA_FILENAME
      )

      expect_info_message(
        outcome,
        <<~MSG.chomp
          Patient Summary Problems Section (11450-4)

          entry[0]: **urn:uuid:310f1593-d610-4144-a6e8-1f823d955e0d** -> Condition (no meta.profile)
        MSG
      )
    end

    it 'It should return info message with details when reference is resolved with meta.profile' do
      outcome = run_with_fixture_bundle_for(
        test_method: :test_composition_mandatory_sections,
        fixture_filename: ERROR_MS_BUNDLE_FILENAME,
        metadata_fixture_filename: METADATA_FILENAME
      )

      expect_info_message(
        outcome,
        <<~MSG.chomp
          Patient Summary Allergies and Intolerances Section (48765-2)

          entry[0]: **urn:uuid:ad6fb7b7-c76f-441e-88a5-9051e795db26** -> AllergyIntolerance (meta.profile: http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-allergyintolerance)

          entry[1]: **urn:uuid:06ba95f5-345b-412d-aa66-99e354470015** -> AllergyIntolerance (no meta.profile)

          entry[2]: **urn:uuid:d24db2d5-3400-4158-892c-d018acdeba09** -> AllergyIntolerance (no meta.profile)
        MSG
      )
    end

    it 'It should return error message with details when reference is resolved but resource type is not permitted' do
      outcome = run_with_fixture_bundle_for(
        test_method: :test_composition_mandatory_sections,
        fixture_filename: ERROR_MS_BUNDLE_FILENAME,
        metadata_fixture_filename: METADATA_FILENAME
      )

      expect_error_message(
        outcome,
        <<~MSG.chomp
          Patient Summary Medication Summary Section (10160-0)

          entry[0]: **urn:uuid:347e8435-cea1-4e94-9755-abb027926bb1** -> ❌ Invalid resource type
        MSG
      )
    end
  end
end
