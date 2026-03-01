# frozen_string_literal: true

class Generator
  # Holds the static test definitions for au_ps_summary_bundle_group.
  #
  # One valid-bundle test (SummaryValidBundleClass) plus six BasicTest tests for must-support
  # and composition sections. Structure mirrors {RetrieveBundleGroupTests}.
  module SummaryBundleGroupTests
    # Array of test spec hashes: file_base, class_base, id_base, title, description,
    # base_class_require, base_class_name, description_comment, run_code.
    TESTS = [
      {
        file_base: 'au_ps_summary_valid_bundle',
        class_base: 'AUPSSummaryValidBundle',
        id_base: 'au_ps_summary_valid_bundle',
        title: 'Server generates AU Patient Summary using IPS $summary operation',
        description: 'Generate AU Patient Summary using IPS $summary operation and verify response is valid ' \
                     'AU PS Bundle',
        base_class_require: '../../utils/summary_valid_bundle_class',
        base_class_name: 'SummaryValidBundleClass',
        description_comment: 'The Bundle resource is valid against the AU PS Bundle profile',
        run_code: nil
      },
      {
        file_base: 'au_ps_summary_bundle_has_must_support_elements',
        class_base: 'AUPSSummaryBundleHasMUSTSUPPORTElements',
        id_base: 'au_ps_summary_bundle_has_must_support_elements',
        title: 'AU PS Bundle has Must Support elements  (Must Have)',
        description: 'Verify the Must Support elements are correctly populated in the AU PS Bundle resource.',
        base_class_require: '../../utils/basic_test_class',
        base_class_name: 'BasicTest',
        description_comment: 'Verify the Must Support elements are correctly populated in the AU PS Bundle resource.',
        run_code: nil
      },
      {
        file_base: 'au_ps_summary_bundle_composition_must_support_elements',
        class_base: 'AUPSSummaryBundleCompositionMUSTSUPPORTElements',
        id_base: 'au_ps_summary_bundle_composition_must_support_elements',
        title: 'AU PS Composition Must Support Elements (Must Have)',
        description: 'Verify the Must Support elements are correctly populated in the AU PS Composition resource.',
        base_class_require: '../../utils/basic_test_class',
        base_class_name: 'BasicTest',
        description_comment: 'Verify the Must Support elements are correctly populated in the AU PS Composition resource.',
        run_code: nil
      },
      {
        file_base: 'au_ps_summary_bundle_composition_mandatory_sections',
        class_base: 'AUPSSummaryBundleCompositionMandatorySection',
        id_base: 'au_ps_summary_bundle_composition_mandatory_sections',
        title: 'AU PS Composition Mandatory Sections (Must Have)',
        description: 'Displays information about mandatory sections (Allergies and Intolerances, ' \
                     'Medication Summary, Problem List) in the Composition resource, including the entry references ' \
                     'within each section.',
        base_class_require: '../../utils/basic_test_class',
        base_class_name: 'BasicTest',
        description_comment: 'The mandatory sections populated in the Composition resource.',
        run_code: nil
      },
      {
        file_base: 'au_ps_summary_bundle_composition_recommended_sections',
        class_base: 'AUPSSummaryBundleCompositionRecommendedSection',
        id_base: 'au_ps_summary_bundle_composition_recommended_sections',
        title: 'AU PS Composition Recommended Sections (Must Have)',
        description: 'Displays information about recommended sections',
        base_class_require: '../../utils/basic_test_class',
        base_class_name: 'BasicTest',
        description_comment: 'The recommended sections populated in the Composition resource.',
        run_code: nil
      },
      {
        file_base: 'au_ps_summary_bundle_composition_optional_sections',
        class_base: 'AUPSSummaryBundleCompositionOptionalSection',
        id_base: 'au_ps_summary_bundle_composition_optional_sections',
        title: 'AU PS Composition Optional Sections (Must Have)',
        description: 'Displays information about optional sections',
        base_class_require: '../../utils/basic_test_class',
        base_class_name: 'BasicTest',
        description_comment: 'The optional sections populated in the Composition resource.',
        run_code: nil
      },
      {
        file_base: 'au_ps_summary_bundle_composition_other_sections',
        class_base: 'AUPSSummaryBundleCompositionOtherSection',
        id_base: 'au_ps_summary_bundle_composition_other_sections',
        title: 'AU PS Composition Undefined Sections (Must Have)',
        description: 'Displays information about other sections',
        base_class_require: '../../utils/basic_test_class',
        base_class_name: 'BasicTest',
        description_comment: 'AU PS Composition Other Sections',
        run_code: nil
      }
    ].freeze
  end
end
