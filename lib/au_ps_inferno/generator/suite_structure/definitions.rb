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
        name: 'Patient Summary Bundle Validation Tests',
        description: 'Validates that the Bundle resource conforms to the AU Patient Summary profiles.',
        tests: [BUNDLE_VALIDATION_PLACEHOLDER, BUNDLE_VALIDATION_IPS_PLACEHOLDER],
        run_as_group: true
      },
      {
        name: 'AU PS Bundle Conformance Tests',
        description: 'Verifies the Bundle resource is populated according to AU PS Bundle conformance requirements.',
        tests: [
          { id: :bundle_must_support_populated }
        ],
        run_as_group: true
      },
      {
        name: 'AU PS Composition Conformance Tests',
        description: 'Verifies the Composition resource is populated according to AU PS Composition ' \
                     'conformance requirements.',
        tests: [
          { id: :composition_must_support_populated }
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
          { id: :author_ms_identifier_slices }
        ],
        run_as_group: true
      },
      {
        name: 'AU PS Composition Custodian',
        description: 'Verify the referenced custodian is a correctly populated AU PS Organization resource.',
        tests: [
          { id: :custodian_ms_elements },
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
        bundle_validation_title: 'Bundle resource is a valid AU Patient Summary',
        bundle_validation_description: 'The Bundle resource is valid against the AU PS profiles using FHIR validator',
        bundle_validation_base_class_name: 'BundleIsValidClass',
        bundle_validation_imports: ['../../../utils/bundle_is_valid_class', '../../../utils/ips_bundle_is_valid_class'],
        bundle_validation_ips_title: 'Bundle resource is a valid IPS',
        bundle_validation_ips_description: 'The Bundle resource is valid against the IPS profiles using FHIR validator',
        bundle_validation_ips_base_class_name: 'IpsBundleIsValidClass',
        run_as_group: true
      },
      {
        name: 'Retrieve AU PS Bundle validation tests',
        description: 'Retrieve document Bundle using Bundle read interaction or other HTTP GET request ' \
                     'and verify response is valid AU PS Bundle',
        bundle_validation_title: 'Retrieved Bundle resource is a valid AU Patient Summary',
        bundle_validation_description: 'Verifies that a Bundle retrieved from the server conforms to the ' \
                                       'AU PS profiles.',
        bundle_validation_base_class_name: 'RetrieveBundleTestClass',
        bundle_validation_imports: ['../../../utils/retrieve_bundle_test_class',
                                    '../../../utils/ips_retrieve_bundle_test_class'],
        bundle_validation_ips_title: 'Retrieved Bundle resource is a valid IPS',
        bundle_validation_ips_description: 'Verifies that a Bundle retrieved from the server conforms to the ' \
                                           'IPS profiles.',
        bundle_validation_ips_base_class_name: 'IpsRetrieveBundleTestClass',
        run_as_group: true
      },
      {
        name: 'Generate AU PS using IPS $summary validation tests',
        description: 'Generate AU Patient Summary using IPS $summary operation and verify response is ' \
                     'valid AU PS Bundle',
        bundle_validation_title: 'Generated Bundle resource is a valid AU Patient Summary',
        bundle_validation_description: 'Verifies that a Bundle produced by the IPS $summary operation ' \
                                       'conforms to the AU PS profiles.',
        bundle_validation_base_class_name: 'SummaryValidBundleClass',
        bundle_validation_imports: ['../../../utils/summary_valid_bundle_class',
                                    '../../../utils/ips_summary_valid_bundle_class'],
        bundle_validation_ips_title: 'Generated Bundle resource is a valid IPS',
        bundle_validation_ips_description: 'Verifies that a Bundle produced by the IPS $summary operation ' \
                                           'conforms to the IPS profiles.',
        bundle_validation_ips_base_class_name: 'IpsSummaryValidBundleClass',
        run_as_group: true
      }
    ].freeze
  end
end
# rubocop:enable Metrics/ModuleLength
