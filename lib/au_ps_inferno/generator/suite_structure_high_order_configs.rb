# frozen_string_literal: true

class Generator
  module SuiteStructure
    HIGH_ORDER_GROUP_CONFIGS = [
      {
        name: 'AU PS Bundle Instance',
        description: 'Validates a static AU PS bundle instance for profile conformance, Must Support ' \
                     'elements, and composition sections.',
        bundle_validation_title: 'AU PS Bundle is valid against AU PS Bundle profile',
        bundle_validation_description: 'The Bundle resource is valid against the AU PS Bundle profile ' \
                                       'using FHIR validator',
        bundle_validation_base_class_name: 'BundleIsValidClass',
        bundle_validation_imports: ['../../../utils/bundle_is_valid_class'],
        run_as_group: true
      },
      {
        name: 'Retrieve AU PS Bundle validation tests',
        description: 'Retrieve document Bundle using Bundle read interaction or other HTTP GET request ' \
                     'and verify response is valid AU PS Bundle',
        bundle_validation_title: 'Retrieved Bundle is valid against AU PS Bundle profile',
        bundle_validation_description: 'Verifies that a bundle retrieved from the server conforms to ' \
                                       'the AU PS Bundle profile.',
        bundle_validation_base_class_name: 'RetrieveBundleTestClass',
        bundle_validation_imports: ['../../../utils/retrieve_bundle_test_class'],
        run_as_group: true
      },
      {
        name: 'Generate AU PS using IPS $summary validation tests',
        description: 'Generate AU Patient Summary using IPS $summary operation and verify response ' \
                     'is valid AU PS Bundle',
        bundle_validation_title: 'Generated Bundle is valid against AU PS Bundle profile',
        bundle_validation_description: 'Verifies that a bundle produced by the IPS $summary operation ' \
                                       'conforms to the AU PS Bundle profile.',
        bundle_validation_base_class_name: 'SummaryValidBundleClass',
        bundle_validation_imports: ['../../../utils/summary_valid_bundle_class'],
        run_as_group: true
      }
    ].freeze
  end
end
