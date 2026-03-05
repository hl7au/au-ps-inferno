# frozen_string_literal: true

class Generator
  # Single source of truth for suite structure: shared group definitions and high-order groups.
  # Edit here to add or change groups/tests; avoid duplicating structure in the main Generator.
  #
  # Tests are referenced by symbol id. Add a new test type: add { id: :new_id } to the appropriate group
  # in SHARED_GROUP_DEFINITIONS and register title/description/config in TestConfigRegistry.
  # :bundle_valid is a special case; its title/description/config come from HIGH_ORDER_GROUP_CONFIGS.
  #
  # To add a new high-order group: add an entry to HIGH_ORDER_GROUP_CONFIGS.
  # To add a new shared group: add to SHARED_GROUP_DEFINITIONS with tests: [ { id: :... }, ... ].
  module SuiteStructure
    # Placeholder for the single test in "Bundle Validation"; each high-order group supplies its own
    # title, description, and base class via HIGH_ORDER_GROUP_CONFIGS.
    BUNDLE_VALIDATION_PLACEHOLDER = :bundle_valid

    # Shared group definitions: name, description, and list of test ids (or BUNDLE_VALIDATION_PLACEHOLDER).
    # Optional keys per group: optional (true/false), run_as_group (true/false).
    SHARED_GROUP_DEFINITIONS = [
      {
        name: 'AU PS Bundle Validation',
        description: 'Validates that the bundle conforms to the AU PS Bundle profile.',
        tests: [BUNDLE_VALIDATION_PLACEHOLDER],
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
        description: 'Verifies that Composition Must Support elements (mandatory, optional, sub-elements, slices) are correctly populated when data is known.',
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
          { id: :sections_entry_profiles }
        ],
        run_as_group: true
      },
      {
        name: 'AU PS Composition Recommended Sections',
        description: 'Verify the recommended sections are correctly populated in the Composition resource',
        tests: [
          { id: :sections_should_populated }
        ],
        optional: true,
        run_as_group: true
      },
      {
        name: 'AU PS Composition Optional Sections',
        description: 'Verify the optional sections are correctly populated in the AU PS Composition resource',
        tests: [
          { id: :sections_may_populated }
        ],
        optional: true,
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
      }
    ].freeze

    # High-order group configs: display name, description, and for the bundle validation test:
    # bundle_validation_title, bundle_validation_description, bundle_validation_base_class_name, bundle_validation_imports.
    # Optional keys per high-order group: optional (true/false), run_as_group (true/false).
    HIGH_ORDER_GROUP_CONFIGS = [
      {
        name: 'AU PS Bundle Instance',
        description: 'Validates a static AU PS bundle instance for profile conformance, Must Support elements, and composition sections.',
        bundle_validation_title: 'AU PS Bundle is valid against AU PS Bundle profile',
        bundle_validation_description: 'The Bundle resource is valid against the AU PS Bundle profile using FHIR validator',
        bundle_validation_base_class_name: 'BundleIsValidClass',
        bundle_validation_imports: ['../../../utils/bundle_is_valid_class'],
        run_as_group: true
      },
      {
        name: 'Retrieve AU PS Bundle validation tests',
        description: 'Retrieve document Bundle using Bundle read interaction or other HTTP GET request and verify response is valid AU PS Bundle',
        bundle_validation_title: 'Retrieved Bundle is valid against AU PS Bundle profile',
        bundle_validation_description: 'Verifies that a bundle retrieved from the server conforms to the AU PS Bundle profile.',
        bundle_validation_base_class_name: 'RetrieveBundleTestClass',
        bundle_validation_imports: ['../../../utils/retrieve_bundle_test_class'],
        run_as_group: true
      },
      {
        name: 'Generate AU PS using IPS $summary validation tests',
        description: 'Generate AU Patient Summary using IPS $summary operation and verify response is valid AU PS Bundle',
        bundle_validation_title: 'Generated Bundle is valid against AU PS Bundle profile',
        bundle_validation_description: 'Verifies that a bundle produced by the IPS $summary operation conforms to the AU PS Bundle profile.',
        bundle_validation_base_class_name: 'SummaryValidBundleClass',
        bundle_validation_imports: ['../../../utils/summary_valid_bundle_class'],
        run_as_group: true
      }
    ].freeze

    # Builds the full HIGH_ORDER_GROUPS structure expected by Generator (array of hashes with :name, :description, :groups).
    # Each group's tests are hashes with :id and, for :bundle_valid, :title, :description, :base_class_name, :imports, :ignore_commands.
    #
    # @return [Array<Hash>] same shape as the former Generator::HIGH_ORDER_GROUPS with :description added
    def self.expand_high_order_groups
      HIGH_ORDER_GROUP_CONFIGS.map do |config|
        groups = SHARED_GROUP_DEFINITIONS.map do |group_def|
          tests = group_def[:tests].map do |t|
            if t == BUNDLE_VALIDATION_PLACEHOLDER
              {
                id: :bundle_valid,
                title: config[:bundle_validation_title],
                description: config[:bundle_validation_description],
                base_class_name: config[:bundle_validation_base_class_name],
                imports: config[:bundle_validation_imports],
                ignore_commands: true
              }
            else
              { id: t[:id] }
            end
          end
          group = { name: group_def[:name], description: group_def[:description], tests: tests }
          group[:optional] = group_def[:optional] if group_def.key?(:optional)
          group[:run_as_group] = group_def[:run_as_group] if group_def.key?(:run_as_group)
          group
        end
        high_order = { name: config[:name], description: config[:description], groups: groups }
        high_order[:optional] = config[:optional] if config.key?(:optional)
        high_order[:run_as_group] = config[:run_as_group] if config.key?(:run_as_group)
        high_order
      end
    end
  end
end
