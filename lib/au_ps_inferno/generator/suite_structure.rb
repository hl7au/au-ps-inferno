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

    # Shared group definitions: name and list of test names (or BUNDLE_VALIDATION_PLACEHOLDER).
    # Used by all high-order groups that validate bundles; only the bundle validation test title varies.
    SHARED_GROUP_DEFINITIONS = [
      {
        name: 'Bundle Validation',
        tests: [BUNDLE_VALIDATION_PLACEHOLDER]
      },
      {
        name: 'Bundle has Must Support elements',
        tests: [
          { name: 'Must Support elements SHALL be populated when an element value is known and allowed to share' }
        ]
      },
      {
        name: 'Composition Must Support elements',
        tests: [
          { name: 'Mandatory Must Support element SHALL be able to be populated if a value is known and allowed to share' },
          { name: 'Optional Must Support elements SHALL be correctly populated if a value is known' },
          { name: 'Must Support sub-elements of a complex element SHALL be correctly populated if a value is known' },
          { name: 'Optional Must Support slices SHALL be populated if a value is known' }
        ]
      },
      {
        name: 'Composition Mandatory Sections',
        tests: [
          { name: 'Sections SHALL be correctly populated if a value is known' },
          { name: 'Sections SHALL be capable of populating section.entry with the referenced profiles, and SHOULD correctly populate section.entry if a value is known' }
        ]
      },
      {
        name: 'Composition Recommended Sections',
        tests: [
          { name: 'Sections SHOULD be correctly populated if a value is known' }
        ]
      },
      {
        name: 'Composition Optional Sections',
        tests: [
          { name: 'Sections MAY be correctly populated if a value is known' }
        ]
      },
      {
        name: 'Composition Undefined Sections',
        tests: [
          { name: 'Sections MAY be populated' }
        ]
      }
    ].freeze

    # High-order group configs: display name and the title for the bundle validation test in "Bundle Validation" group.
    HIGH_ORDER_GROUP_CONFIGS = [
      {
        name: 'AU PS Bundle Instance',
        bundle_validation_title: 'Bundle is valid against AU PS Bundle profile'
      },
      {
        name: 'Retrieve Bundle validation',
        bundle_validation_title: 'Retrieved Bundle is valid against AU PS Bundle profile'
      },
      {
        name: 'Generate Bundle using IPS $summary validation',
        bundle_validation_title: 'Generated Bundle is valid against AU PS Bundle profile'
      }
    ].freeze

    # Builds the full HIGH_ORDER_GROUPS structure expected by Generator (array of hashes with :name and :groups).
    #
    # @return [Array<Hash>] same shape as the former Generator::HIGH_ORDER_GROUPS
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
          { name: group_def[:name], tests: tests }
        end
        { name: config[:name], groups: groups }
      end
    end
  end
end
