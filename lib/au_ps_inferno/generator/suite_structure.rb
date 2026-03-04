# frozen_string_literal: true

class Generator
  # Single source of truth for suite structure: shared group definitions and high-order groups.
  # Edit here to add or change groups/tests; avoid duplicating structure in the main Generator.
  #
  # To add a new high-order group: add an entry to HIGH_ORDER_GROUP_CONFIGS.
  # To add a new shared group: add to SHARED_GROUP_DEFINITIONS and ensure test names
  # have config in TestConfigRegistry (or default BasicTest will be used).
  # To add a new test type: add the test name to the appropriate group in SHARED_GROUP_DEFINITIONS
  # and register config in TestConfigRegistry.
  module SuiteStructure
    # Placeholder used for the single test in "Bundle Validation" so each high-order group
    # can supply its own title (e.g. "Bundle is valid...", "Retrieved Bundle is valid...", "Generated Bundle is valid...").
    BUNDLE_VALIDATION_PLACEHOLDER = :bundle_validation_placeholder

    # Shared group definitions: name, description, and list of test names (or BUNDLE_VALIDATION_PLACEHOLDER).
    # Optional keys per group: optional (true/false), run_as_group (true/false).
    # Used by all high-order groups that validate bundles; only the bundle validation test title varies.
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
          { name: 'Must Support elements SHALL be populated when an element value is known and allowed to share' }
        ],
        run_as_group: true
      },
      {
        name: 'AU PS Composition Must Support Conformance',
        description: 'Verifies that Composition Must Support elements (mandatory, optional, sub-elements, slices) are correctly populated when data is known.',
        tests: [
          { name: 'Mandatory Must Support element SHALL be able to be populated if a value is known and allowed to share' },
          { name: 'Optional Must Support elements SHALL be correctly populated if a value is known' },
          { name: 'Must Support sub-elements of a complex element SHALL be correctly populated if a value is known' },
          { name: 'Optional Must Support slices SHALL be populated if a value is known' }
        ],
        run_as_group: true
      },
      {
        name: 'AU PS Composition Mandatory Sections',
        description: 'Verifies that mandatory sections are present and section.entry references conform to the required profiles.',
        tests: [
          { name: 'Sections SHALL be correctly populated if a value is known' },
          { name: 'Sections SHALL be capable of populating section.entry with the referenced profiles, and SHOULD correctly populate section.entry if a value is known' }
        ],
        run_as_group: true
      },
      {
        name: 'AU PS Composition Recommended Sections',
        description: 'Verifies that recommended (SHOULD) sections are correctly populated when data is known.',
        tests: [
          { name: 'Sections SHOULD be correctly populated if a value is known' }
        ],
        optional: true,
        run_as_group: true
      },
      {
        name: 'AU PS Composition Optional Sections',
        description: 'Verify the optional sections are correctly populated in the AU PS Composition',
        tests: [
          { name: 'Sections MAY be correctly populated if a value is known' }
        ],
        optional: true,
        run_as_group: true
      },
      {
        name: 'AU PS Composition Undefined Sections',
        description: 'Verify the undefined sections are correctly populated in the AU PS Composition resource.',
        tests: [
          { name: 'Sections MAY be populated' }
        ],
        optional: true,
        run_as_group: true
      }
    ].freeze

    # High-order group configs: display name, description, bundle_validation_title.
    # Optional keys per high-order group: optional (true/false), run_as_group (true/false).
    HIGH_ORDER_GROUP_CONFIGS = [
      {
        name: 'AU PS Bundle Instance',
        description: 'Validates a static AU PS bundle instance for profile conformance, Must Support elements, and composition sections.',
        bundle_validation_title: 'AU PS Bundle Must Support elements are correctly populated',
        run_as_group: true
      },
      {
        name: 'Retrieve AU PS Bundle validation tests',
        description: 'Retrieve document Bundle using Bundle read interaction or other HTTP GET request and verify response is valid AU PS Bundle',
        bundle_validation_title: 'Retrieved Bundle is valid against AU PS Bundle profile',
        run_as_group: true
      },
      {
        name: 'Generate AU PS using IPS $summary validation tests',
        description: 'Generate AU Patient Summary using IPS $summary operation and verify response is valid AU PS Bundle',
        bundle_validation_title: 'Generated Bundle is valid against AU PS Bundle profile',
        run_as_group: true
      }
    ].freeze

    # Builds the full HIGH_ORDER_GROUPS structure expected by Generator (array of hashes with :name, :description, :groups).
    #
    # @return [Array<Hash>] same shape as the former Generator::HIGH_ORDER_GROUPS with :description added
    def self.expand_high_order_groups
      HIGH_ORDER_GROUP_CONFIGS.map do |config|
        groups = SHARED_GROUP_DEFINITIONS.map do |group_def|
          tests = group_def[:tests].map do |t|
            if t == BUNDLE_VALIDATION_PLACEHOLDER
              { name: config[:bundle_validation_title] }
            else
              t
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
