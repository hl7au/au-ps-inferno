# frozen_string_literal: true

class Generator
  # Holds the static test definitions for au_ps_retrieve_bundle_group (one valid-bundle test plus
  # six BasicTest tests for must-support and composition sections).
  module RetrieveBundleGroupTests
    TESTS = [
      {
        file_base: 'au_ps_retrieve_valid_bundle',
        class_base: 'AUPSRetrieveValidBundle',
        id_base: 'au_ps_retrieve_valid_bundle',
        title: 'Server provides valid requested AU PS Bundle',
        description: 'Retrieve document Bundle using Bundle read interaction or other HTTP GET request and ' \
                     'verify response is valid AU PS Bundle',
        base_class_require: '../../utils/retrieve_bundle_test_class',
        base_class_name: 'RetrieveBundleTestClass',
        description_comment: 'The Bundle resource is valid against the AU PS Bundle profile',
        run_code: nil
      },
      {
        file_base: 'au_ps_retrieve_bundle_has_must_support_elements',
        class_base: 'AUPSRetrieveBundleHasMUSTSUPPORTElements',
        id_base: 'au_ps_retrieve_bundle_has_must_support_elements',
        title: 'Bundle has mandatory must-support elements',
        description: 'Checks that the Bundle resource contains mandatory must-support elements (identifier, ' \
                     'type, timestamp) and that all entries have a fullUrl. Also provides information about the ' \
                     'resource types included in the Bundle.',
        base_class_require: '../../utils/basic_test_class',
        base_class_name: 'BasicTest',
        description_comment: 'The Must Support elements populated in the Bundle resource.',
        run_code: nil
      },
      {
        file_base: 'au_ps_retrieve_bundle_composition_must_support_elements',
        class_base: 'AUPSRetrieveBundleCompositionMUSTSUPPORTElements',
        id_base: 'au_ps_retrieve_bundle_composition_must_support_elements',
        title: 'Composition has must-support elements',
        description: 'Checks that the Composition resource contains mandatory must-support elements ' \
                     '(status, type, subject.reference, date, author, title, section.title, section.text) and ' \
                     'provides information about optional must-support elements ' \
                     '(text, identifier, attester, custodian, event).',
        base_class_require: '../../utils/basic_test_class',
        base_class_name: 'BasicTest',
        description_comment: 'The Must Support elements populated in the Composition resource.',
        run_code: nil
      },
      {
        file_base: 'au_ps_retrieve_bundle_composition_mandatory_sections',
        class_base: 'AUPSRetrieveBundleCompositionMandatorySection',
        id_base: 'au_ps_retrieve_bundle_composition_mandatory_sections',
        title: 'Composition contains mandatory sections with entry references',
        description: 'Displays information about mandatory sections (Allergies and Intolerances, ' \
                     'Medication Summary, Problem List) in the Composition resource, including the entry references ' \
                     'within each section.',
        base_class_require: '../../utils/basic_test_class',
        base_class_name: 'BasicTest',
        description_comment: 'The mandatory sections populated in the Composition resource.',
        run_code: nil
      },
      {
        file_base: 'au_ps_retrieve_bundle_composition_recommended_sections',
        class_base: 'AUPSRetrieveBundleCompositionRecommendedSection',
        id_base: 'au_ps_retrieve_bundle_composition_recommended_sections',
        title: 'Composition contains recommended sections with entry references',
        description: 'Displays information about recommended sections',
        base_class_require: '../../utils/basic_test_class',
        base_class_name: 'BasicTest',
        description_comment: 'The recommended sections populated in the Composition resource.',
        run_code: nil
      },
      {
        file_base: 'au_ps_retrieve_bundle_composition_optional_sections',
        class_base: 'AUPSRetrieveBundleCompositionOptionalSection',
        id_base: 'au_ps_retrieve_bundle_composition_optional_sections',
        title: 'Composition contains optional sections with entry references',
        description: 'Displays information about optional sections',
        base_class_require: '../../utils/basic_test_class',
        base_class_name: 'BasicTest',
        description_comment: 'The optional sections populated in the Composition resource.',
        run_code: nil
      },
      {
        file_base: 'au_ps_retrieve_bundle_composition_other_sections',
        class_base: 'AUPSRetrieveBundleCompositionOtherSection',
        id_base: 'au_ps_retrieve_bundle_composition_other_sections',
        title: 'Composition contains other sections with entry references',
        description: 'Displays information about other sections',
        base_class_require: '../../utils/basic_test_class',
        base_class_name: 'BasicTest',
        description_comment: 'AU PS Composition Other Sections',
        run_code: nil
      }
    ].freeze
  end
end
