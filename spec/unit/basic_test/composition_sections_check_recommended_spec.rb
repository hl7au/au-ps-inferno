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

    it 'fails when mandatory MS elements are missing in recommended sections' do
      outcome = run_with_fixture_bundle(test, fixture_filename: error_bundle_filename)

      expect_fail(outcome)
    end

    it 'returns an info message when all mandatory and optional elements are populated' do
      outcome = run_with_fixture_bundle(test, fixture_filename: success_bundle_filename)

      expect_info_message(
        outcome,
        <<~MSG.chomp
          All Must Support elements are populated in the Patient Summary Immunizations Section (11369-6) section.

          **Profile**: Immunization — http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-immunization

          List of Must Support elements populated or missing

          Immunization/cccccccc-0001-0000-0000-000000000006: status: ✅ Populated (M)

          Immunization/cccccccc-0001-0000-0000-000000000006: vaccineCode: ✅ Populated (M)

          Immunization/cccccccc-0001-0000-0000-000000000006: patient: ✅ Populated (M)

          Immunization/cccccccc-0001-0000-0000-000000000006: patient.reference: ✅ Populated (M)

          Immunization/cccccccc-0001-0000-0000-000000000006: occurrenceDateTime: ✅ Populated

          Immunization/cccccccc-0001-0000-0000-000000000006: primarySource: ✅ Populated

          Immunization/cccccccc-0001-0000-0000-000000000006: lotNumber: ✅ Populated

          Immunization/cccccccc-0001-0000-0000-000000000006: note: ✅ Populated
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

          Observation/cccccccc-0001-0000-0000-000000000007: status: ✅ Populated (M)

          Observation/cccccccc-0001-0000-0000-000000000007: category: ✅ Populated (M)

          Observation/cccccccc-0001-0000-0000-000000000007: code: ✅ Populated (M)

          Observation/cccccccc-0001-0000-0000-000000000007: subject: ✅ Populated (M)

          Observation/cccccccc-0001-0000-0000-000000000007: subject.reference: ✅ Populated (M)

          Observation/cccccccc-0001-0000-0000-000000000007: effectiveDateTime: ✅ Populated

          Observation/cccccccc-0001-0000-0000-000000000007: performer: ✅ Populated (M)

          Observation/cccccccc-0001-0000-0000-000000000007: value[x]: ⚠️ Missing

          Observation/cccccccc-0001-0000-0000-000000000007: dataAbsentReason: ⚠️ Missing

          Observation/cccccccc-0001-0000-0000-000000000007: interpretation: ⚠️ Missing

          Observation/cccccccc-0001-0000-0000-000000000007: specimen: ⚠️ Missing

          Observation/cccccccc-0001-0000-0000-000000000007: referenceRange: ⚠️ Missing

          Observation/cccccccc-0001-0000-0000-000000000007: hasMember: ⚠️ Missing

          Observation/cccccccc-0001-0000-0000-000000000007: component: ✅ Populated

          Observation/cccccccc-0001-0000-0000-000000000007: component.code: ✅ Populated (M)

          Observation/cccccccc-0001-0000-0000-000000000007: component.value[x]: ✅ Populated

          Observation/cccccccc-0001-0000-0000-000000000007: component.dataAbsentReason: ⚠️ Missing
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

          Immunization/cccccccc-0002-0000-0000-000000000006: status: ✅ Populated (M)

          Immunization/cccccccc-0002-0000-0000-000000000006: vaccineCode: ❌ Missing (M)

          Immunization/cccccccc-0002-0000-0000-000000000006: patient: ✅ Populated (M)

          Immunization/cccccccc-0002-0000-0000-000000000006: patient.reference: ✅ Populated (M)

          Immunization/cccccccc-0002-0000-0000-000000000006: occurrenceDateTime: ✅ Populated

          Immunization/cccccccc-0002-0000-0000-000000000006: primarySource: ✅ Populated

          Immunization/cccccccc-0002-0000-0000-000000000006: lotNumber: ⚠️ Missing

          Immunization/cccccccc-0002-0000-0000-000000000006: note: ✅ Populated
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

    context 'when a section entry reference does not resolve (resource not in bundle)' do
      let(:unresolved_ref_bundle_filename) { 'recommended-error-unresolved-ref-bundle.json' }

      it 'fails the test when an entry reference cannot be resolved' do
        outcome = run_with_fixture_bundle(test, fixture_filename: unresolved_ref_bundle_filename)

        expect_fail(outcome)
      end

      it 'returns an error message when an entry reference cannot be resolved' do
        outcome = run_with_fixture_bundle(test, fixture_filename: unresolved_ref_bundle_filename)

        expect_error_message(
          outcome,
          <<~MSG.chomp
            Patient Summary Immunizations Section (11369-6)

            entry[0]: **urn:uuid:cccccccc-0005-0000-0000-000000000006** -> Immunization (no meta.profile)

            **urn:uuid:cccccccc-0005-0000-0000-000000000099** -> ❌ Reference does not resolve
          MSG
        )
      end
    end
  end
end
