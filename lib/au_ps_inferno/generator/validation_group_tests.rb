# frozen_string_literal: true

class Generator
  # Holds the static test definitions for au_ps_validation_group.
  #
  # One bundle-is-valid test (BundleIsValidClass) plus six BasicTest tests for must-support
  # and composition sections. Validates a user-provided Bundle (no FHIR client).
  module ValidationGroupTests
    # Array of test spec hashes: file_base, class_base, id_base, title, description,
    # base_class_require, base_class_name, description_comment, run_code.
    TESTS = [
      {
        file_base: 'au_ps_bundle_is_valid_test',
        class_base: 'AUPSBundleIsValidTest',
        id_base: 'au_ps_bundle_is_valid_test',
        title: 'AU PS Bundle is valid',
        description: 'Validates that a Bundle resource conforms to the AU PS Bundle profile ' \
                     '(http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle). The test accepts a ' \
                     'pre-existing Bundle resource to validate directly.',
        base_class_require: '../../utils/bundle_is_valid_class',
        base_class_name: 'BundleIsValidClass',
        description_comment: 'The Bundle resource is valid against the AU PS Bundle profile',
        run_code: nil
      },
      {
        file_base: 'au_ps_bundle_has_must_support_elements',
        class_base: 'AUPSBundleHasMUSTSUPPORTElements',
        id_base: 'au_ps_bundle_has_must_support_elements',
        title: 'Bundle has mandatory must-support elements',
        description: 'Checks that the Bundle resource contains mandatory must-support elements (identifier, ' \
                     'type, timestamp) and that all entries have a fullUrl. Also provides information about the ' \
                     'resource types included in the Bundle.',
        base_class_require: '../../utils/basic_test_class',
        base_class_name: 'BasicTest',
        description_comment: 'Verify the Must Support elements are correctly populated in the AU PS Bundle resource.',
        run_code: 'bundle_mandatory_ms_elements_info'
      },
      {
        file_base: 'au_ps_composition_must_support_elements',
        class_base: 'AUPSCompositionMUSTSUPPORTElements',
        id_base: 'au_ps_composition_must_support_elements',
        title: 'Composition has must-support elements',
        description: 'Checks that the Composition resource contains mandatory must-support elements ' \
                     '(status, type, subject.reference, date, author, title, section.title, section.text) and ' \
                     'provides information about optional must-support elements ' \
                     '(text, identifier, attester, custodian, event).',
        base_class_require: '../../utils/basic_test_class',
        base_class_name: 'BasicTest',
        description_comment: 'The Must Support elements populated in the Composition resource.',
        run_code: 'composition_mandatory_ms_elements_info'
      },
      {
        file_base: 'au_ps_composition_mandatory_sections',
        class_base: 'AUPSCompositionMandatorySection',
        id_base: 'au_ps_composition_mandatory_sections',
        title: 'Composition contains mandatory sections with entry references',
        description: 'Displays information about mandatory sections (Allergies and Intolerances, ' \
                     'Medication Summary, Problem List) in the Composition resource, including the entry ' \
                     'references within each section.',
        base_class_require: '../../utils/basic_test_class',
        base_class_name: 'BasicTest',
        description_comment: 'The mandatory sections populated in the Composition resource.',
        run_code: nil
      },
      {
        file_base: 'au_ps_composition_recommended_sections',
        class_base: 'AUPSCompositionRecommendedSection',
        id_base: 'au_ps_composition_recommended_sections',
        title: 'Composition contains recommended sections with entry references',
        description: 'Displays information about recommended sections',
        base_class_require: '../../utils/basic_test_class',
        base_class_name: 'BasicTest',
        description_comment: 'The recommended sections populated in the Composition resource.',
        run_code: nil
      },
      {
        file_base: 'au_ps_composition_optional_sections',
        class_base: 'AUPSCompositionOptionalSection',
        id_base: 'au_ps_composition_optional_sections',
        title: 'Composition contains optional sections with entry references',
        description: 'Displays information about optional sections',
        base_class_require: '../../utils/basic_test_class',
        base_class_name: 'BasicTest',
        description_comment: 'The optional sections populated in the Composition resource.',
        run_code: nil
      },
      {
        file_base: 'au_ps_composition_other_sections',
        class_base: 'AUPSCompositionOtherSection',
        id_base: 'au_ps_composition_other_sections',
        title: 'Composition contains other sections with entry references',
        description: 'Displays information about other sections',
        base_class_require: '../../utils/basic_test_class',
        base_class_name: 'BasicTest',
        description_comment: 'AU PS Composition Other Sections',
        run_code: 'check_other_sections'
      }
    ].freeze
  end
end
