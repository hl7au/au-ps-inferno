# frozen_string_literal: true

require_relative 'suite_structure/definitions'

class Generator
  # Single source of truth for suite structure: shared group definitions and high-order groups.
  # Edit suite_structure/definitions.rb to add or change groups/tests; avoid duplicating structure in Generator.
  #
  # Tests are referenced by symbol id. Add a new test type: add { id: :new_id } to the appropriate group
  # in SHARED_GROUP_DEFINITIONS and register title/description/config in TestConfigRegistry.
  # :bundle_valid and :bundle_valid_ips are special cases; their title/description/config come from
  # HIGH_ORDER_GROUP_CONFIGS.
  #
  # To add a new high-order group: add an entry to HIGH_ORDER_GROUP_CONFIGS.
  # To add a new shared group: add to SHARED_GROUP_DEFINITIONS with tests: [ { id: :... }, ... ].
  module SuiteStructure
    # Builds the full HIGH_ORDER_GROUPS structure expected by Generator (array of hashes with
    # :name, :description, :groups).
    # Each group's tests are hashes with :id and, for :bundle_valid / :bundle_valid_ips, :title,
    # :description, :base_class_name, :imports, :ignore_commands.
    #
    # @return [Array<Hash>] same shape as the former Generator::HIGH_ORDER_GROUPS with :description added
    def self.expand_high_order_groups
      HIGH_ORDER_GROUP_CONFIGS.map { |config| build_high_order_entry(config) }
    end

    def self.build_high_order_entry(config)
      groups = SHARED_GROUP_DEFINITIONS.map { |group_def| build_shared_group(group_def, config) }
      high_order = { name: config[:name], description: config[:description], groups: groups }
      high_order[:optional] = config[:optional] if config.key?(:optional)
      high_order[:run_as_group] = config[:run_as_group] if config.key?(:run_as_group)
      high_order
    end

    def self.build_shared_group(group_def, config)
      tests = group_def[:tests].map { |t| map_test_item(t, config) }
      group = { name: group_def[:name], description: group_def[:description], tests: tests }
      group[:optional] = group_def[:optional] if group_def.key?(:optional)
      group[:run_as_group] = group_def[:run_as_group] if group_def.key?(:run_as_group)
      group
    end

    def self.map_test_item(test_item, config)
      return bundle_valid_test_hash(config) if test_item == BUNDLE_VALIDATION_PLACEHOLDER
      return bundle_valid_ips_test_hash(config) if test_item == BUNDLE_VALIDATION_IPS_PLACEHOLDER

      { id: test_item[:id] }
    end

    def self.bundle_valid_test_hash(config)
      {
        id: :bundle_valid,
        title: config[:bundle_validation_title],
        description: config[:bundle_validation_description],
        base_class_name: config[:bundle_validation_base_class_name],
        imports: config[:bundle_validation_imports],
        ignore_commands: true
      }
    end

    def self.bundle_valid_ips_test_hash(config)
      {
        id: :bundle_valid_ips,
        title: config[:bundle_validation_ips_title],
        description: config[:bundle_validation_ips_description],
        base_class_name: config[:bundle_validation_ips_base_class_name],
        imports: config[:bundle_validation_imports],
        ignore_commands: true
      }
    end
  end
end
