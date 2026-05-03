# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength
class Generator
  module SuiteStructure
    # Placeholders for the two tests in "Bundle Validation"; each high-order group supplies its own
    # title, description, and base class via HIGH_ORDER_GROUP_CONFIGS.
    BUNDLE_VALIDATION_PLACEHOLDER = :bundle_valid
    BUNDLE_VALIDATION_IPS_PLACEHOLDER = :bundle_valid_ips

    SHARED_GROUP_DEFINITIONS = [
      {
        name: 'Bundle Validation',
        description: 'Validates that the bundle conforms to the Bundle profiles.',
        tests: [BUNDLE_VALIDATION_PLACEHOLDER, BUNDLE_VALIDATION_IPS_PLACEHOLDER],
        run_as_group: true
      },
      {
        name: 'AU PS Bundle Must Support Conformance',
        description: 'Verifies that Must Support elements at the bundle level are populated when data is available.',
        tests: [
          { id: :bundle_must_support_populated }
        ],
        run_as_group: true
      },
      {
        name: 'AU PS Composition Must Support Conformance',
        description: 'Verifies that Composition Must Support elements (mandatory, optional, sub-elements, ' \
                     'slices) are correctly populated when data is known.',
        tests: [
          { id: :composition_mandatory_ms_populated },
          { id: :composition_optional_ms_populated },
          { id: :composition_ms_subelements_populated },
          { id: :composition_optional_ms_slices }
        ],
        run_as_group: true
      },
      {
        name: 'AU PS Composition Mandatory Sections',
        description: 'Verify the mandatory sections are correctly populated in the AU PS Composition resource',
        tests: [
          { id: :sections_shall_populated },
          { id: :mandatory_sections_entry_profiles }
        ],
        run_as_group: true
      },
      {
        name: 'AU PS Composition Recommended Sections',
        description: 'Verify the recommended sections are correctly populated in the Composition resource',
        tests: [
          { id: :sections_should_populated },
          { id: :recommended_sections_entry_profiles }
        ],
        run_as_group: true
      },
      {
        name: 'AU PS Composition Optional Sections',
        description: 'Verify the optional sections are correctly populated in the AU PS Composition resource',
        tests: [
          { id: :sections_may_populated },
          { id: :optional_sections_entry_profiles }
        ],
        run_as_group: true
      },
      {
        name: 'AU PS Composition Undefined Sections',
        description: 'Verify the undefined sections are correctly populated in the AU PS Composition resource.',
        tests: [
          { id: :sections_may_undefined }
        ],
        optional: true,
        run_as_group: true
      },
      {
        name: 'AU PS Composition Subject',
        description: 'Verify the referenced subject is a correctly populated AU PS Patient resource.',
        tests: [
          { id: :subject_resource_type_is_valid },
          { id: :subject_ms_elements },
          { id: :subject_ms_subelements_populated },
          { id: :subject_ms_identifier_slices }
        ],
        run_as_group: true
      },
      {
        name: 'AU PS Composition Author',
        description: 'Verify the referenced author is a correctly populated AU PS Practitioner, ' \
                     'AU PS PractitionerRole, AU PS Patient, AU PS RelatedPerson, AU PS Organization ' \
                     'profiles or Device resource.',
        tests: [
          { id: :author_resource_type_is_valid },
          { id: :author_ms_elements },
          { id: :author_ms_subelements },
          { id: :author_ms_identifier_slices }
        ],
        run_as_group: true
      },
      {
        name: 'AU PS Composition Custodian',
        description: 'Verify the referenced custodian is a correctly populated AU PS Organization resource.',
        tests: [
          { id: :custodian_ms_elements },
          { id: :custodian_ms_subelements },
          { id: :custodian_ms_identifier_slices }
        ],
        optional: true,
        run_as_group: true
      },
      {
        name: 'AU PS Composition Attester',
        description: 'Verify the referenced attester.party is a correctly populated AU PS Patient, ' \
                     'RelatedPerson, Practitioner, PractitionerRole, or Organization resource.',
        tests: [
          { id: :attester_party_ms_elements },
          { id: :attester_party_ms_subelements },
          { id: :attester_party_ms_identifier_slices }
        ],
        optional: true,
        run_as_group: true
      }
    ].freeze

    HIGH_ORDER_GROUP_CONFIGS = [
      {
        name: 'AU PS Bundle Instance',
        description: 'Validates a static AU PS bundle instance for profile conformance, Must Support ' \
                     'elements, and composition sections.',
        bundle_validation_title: 'AU PS Bundle is valid against AU PS Bundle profile',
        bundle_validation_description: 'The Bundle resource is valid against the AU PS Bundle profile ' \
                                       'using FHIR validator',
        bundle_validation_base_class_name: 'BundleIsValidClass',
        bundle_validation_imports: ['../../../utils/bundle_is_valid_class', '../../../utils/ips_bundle_is_valid_class'],
        bundle_validation_ips_title: 'AU PS Bundle is valid against IPS Bundle profile',
        bundle_validation_ips_description: 'The Bundle resource is valid against the IPS Bundle profile ' \
                                           'using FHIR validator',
        bundle_validation_ips_base_class_name: 'IpsBundleIsValidClass',
        run_as_group: true
      },
      {
        name: 'Retrieve AU PS Bundle validation tests',
        description: 'Retrieve document Bundle using Bundle read interaction or other HTTP GET request ' \
                     'and verify response is valid AU PS Bundle',
        bundle_validation_title: 'Retrieved Bundle is valid against AU PS Bundle profile',
        bundle_validation_description: 'Verifies that a bundle retrieved from the server conforms to the ' \
                                       'AU PS Bundle profile.',
        bundle_validation_base_class_name: 'RetrieveBundleTestClass',
        bundle_validation_imports: ['../../../utils/retrieve_bundle_test_class',
                                    '../../../utils/ips_retrieve_bundle_test_class'],
        bundle_validation_ips_title: 'Retrieved Bundle is valid against IPS Bundle profile',
        bundle_validation_ips_description: 'Verifies that a bundle retrieved from the server conforms to the ' \
                                           'IPS Bundle profile.',
        bundle_validation_ips_base_class_name: 'IpsRetrieveBundleTestClass',
        run_as_group: true
      },
      {
        name: 'Generate AU PS using IPS $summary validation tests',
        description: 'Generate AU Patient Summary using IPS $summary operation and verify response is ' \
                     'valid AU PS Bundle',
        bundle_validation_title: 'Generated Bundle is valid against AU PS Bundle profile',
        bundle_validation_description: 'Verifies that a bundle produced by the IPS $summary operation ' \
                                       'conforms to the AU PS Bundle profile.',
        bundle_validation_base_class_name: 'SummaryValidBundleClass',
        bundle_validation_imports: ['../../../utils/summary_valid_bundle_class',
                                    '../../../utils/ips_summary_valid_bundle_class'],
        bundle_validation_ips_title: 'Generated Bundle is valid against IPS Bundle profile',
        bundle_validation_ips_description: 'Verifies that a bundle produced by the IPS $summary operation ' \
                                           'conforms to the IPS Bundle profile.',
        bundle_validation_ips_base_class_name: 'IpsSummaryValidBundleClass',
        run_as_group: true
      }
    ].freeze
  end
end
# rubocop:enable Metrics/ModuleLength
