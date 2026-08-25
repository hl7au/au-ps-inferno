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

    it 'returns an info message when all AllergyIntolerance Must Support elements are populated' do
      outcome = run_with_fixture_bundle(test, fixture_filename: success_bundle_filename)

      expect_info_message(
        outcome,
        msg(<<~MSG)
          All Must Support elements are populated in the Patient Summary Allergies and Intolerances Section (48765-2) section.

          **Profile**: AllergyIntolerance — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-allergyintolerance

          List of Must Support elements populated or missing

          AllergyIntolerance/ad6fb7b7-c76f-441e-88a5-9051e795db26: clinicalStatus: ✅ Populated

          AllergyIntolerance/ad6fb7b7-c76f-441e-88a5-9051e795db26: verificationStatus: ✅ Populated

          AllergyIntolerance/ad6fb7b7-c76f-441e-88a5-9051e795db26: type: ✅ Populated

          AllergyIntolerance/ad6fb7b7-c76f-441e-88a5-9051e795db26: code: ✅ Populated (M)

          AllergyIntolerance/ad6fb7b7-c76f-441e-88a5-9051e795db26: patient: ✅ Populated (M)

          AllergyIntolerance/ad6fb7b7-c76f-441e-88a5-9051e795db26: patient.reference: ✅ Populated (M)

          AllergyIntolerance/ad6fb7b7-c76f-441e-88a5-9051e795db26: onsetDateTime: ✅ Populated

          AllergyIntolerance/ad6fb7b7-c76f-441e-88a5-9051e795db26: note: ✅ Populated

          AllergyIntolerance/ad6fb7b7-c76f-441e-88a5-9051e795db26: reaction: ✅ Populated

          AllergyIntolerance/ad6fb7b7-c76f-441e-88a5-9051e795db26: reaction.manifestation: ✅ Populated (M)

          AllergyIntolerance/ad6fb7b7-c76f-441e-88a5-9051e795db26: reaction.severity: ✅ Populated
        MSG
      )
    end

    it 'returns an info message when all Condition Must Support elements are populated' do
      outcome = run_with_fixture_bundle(test, fixture_filename: success_bundle_filename)

      expect_info_message(
        outcome,
        msg(<<~MSG)
          All Must Support elements are populated in the Patient Summary Problems Section (11450-4) section.

          **Profile**: Condition — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition

          List of Must Support elements populated or missing

          Condition/310f1593-d610-4144-a6e8-1f823d955e0d: clinicalStatus: ✅ Populated

          Condition/310f1593-d610-4144-a6e8-1f823d955e0d: verificationStatus: ✅ Populated

          Condition/310f1593-d610-4144-a6e8-1f823d955e0d: category: ✅ Populated (M)

          Condition/310f1593-d610-4144-a6e8-1f823d955e0d: severity: ✅ Populated

          Condition/310f1593-d610-4144-a6e8-1f823d955e0d: code: ✅ Populated (M)

          Condition/310f1593-d610-4144-a6e8-1f823d955e0d: subject: ✅ Populated (M)

          Condition/310f1593-d610-4144-a6e8-1f823d955e0d: subject.reference: ✅ Populated (M)

          Condition/310f1593-d610-4144-a6e8-1f823d955e0d: onsetDateTime: ✅ Populated

          Condition/310f1593-d610-4144-a6e8-1f823d955e0d: abatement[x]: ✅ Populated

          Condition/310f1593-d610-4144-a6e8-1f823d955e0d: note: ✅ Populated
        MSG
      )
    end

    it 'returns an info message when all MedicationStatement Must Support elements are populated' do
      outcome = run_with_fixture_bundle(test, fixture_filename: success_bundle_filename)

      expect_info_message(
        outcome,
        msg(<<~MSG)
          All Must Support elements are populated in the Patient Summary Medication Summary Section (10160-0) section.

          **Profile**: MedicationStatement — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement

          List of Must Support elements populated or missing

          MedicationStatement/347e8435-cea1-4e94-9755-abb027926bb1: status: ✅ Populated (M)

          MedicationStatement/347e8435-cea1-4e94-9755-abb027926bb1: medication[x]: ✅ Populated (M)

          MedicationStatement/347e8435-cea1-4e94-9755-abb027926bb1: subject: ✅ Populated (M)

          MedicationStatement/347e8435-cea1-4e94-9755-abb027926bb1: subject.reference: ✅ Populated (M)

          MedicationStatement/347e8435-cea1-4e94-9755-abb027926bb1: effectiveDateTime: ✅ Populated

          MedicationStatement/347e8435-cea1-4e94-9755-abb027926bb1: dateAsserted: ✅ Populated

          MedicationStatement/347e8435-cea1-4e94-9755-abb027926bb1: reasonCode: ✅ Populated

          MedicationStatement/347e8435-cea1-4e94-9755-abb027926bb1: reasonReference: ✅ Populated

          MedicationStatement/347e8435-cea1-4e94-9755-abb027926bb1: dosage: ✅ Populated

          MedicationStatement/347e8435-cea1-4e94-9755-abb027926bb1: dosage.text: ✅ Populated

          MedicationStatement/347e8435-cea1-4e94-9755-abb027926bb1: dosage.timing: ✅ Populated
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

          Condition/310f1593-d610-4144-a6e8-1f823d955e0d: clinicalStatus: ✅ Populated

          Condition/310f1593-d610-4144-a6e8-1f823d955e0d: verificationStatus: ⚠️ Missing

          Condition/310f1593-d610-4144-a6e8-1f823d955e0d: category: ❌ Missing (M)

          Condition/310f1593-d610-4144-a6e8-1f823d955e0d: severity: ⚠️ Missing

          Condition/310f1593-d610-4144-a6e8-1f823d955e0d: code: ✅ Populated (M)

          Condition/310f1593-d610-4144-a6e8-1f823d955e0d: subject: ✅ Populated (M)

          Condition/310f1593-d610-4144-a6e8-1f823d955e0d: subject.reference: ✅ Populated (M)

          Condition/310f1593-d610-4144-a6e8-1f823d955e0d: onsetDateTime: ⚠️ Missing

          Condition/310f1593-d610-4144-a6e8-1f823d955e0d: abatement[x]: ⚠️ Missing

          Condition/310f1593-d610-4144-a6e8-1f823d955e0d: note: ⚠️ Missing
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
