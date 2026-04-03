# frozen_string_literal: true

class Generator
  # Registry of test type metadata and config keyed by symbol id.
  # Single source of truth for title, description, and config (base_class, commands, etc.).
  # Add new test types in test_config_registry/entries.rb (REGISTRY hash): keyed by symbol with title:, description:,
  # and optional :base_class_name, :imports, :ignore_commands, :optional, :commands, :commands_builder.
  # :bundle_valid is not in the registry; its title/description/config come from high-order config in SuiteStructure.
  #
  # Keys: Symbol test type id (e.g. :bundle_must_support_populated).
  # Values: hash with :title, :description, and optional :base_class_name, :imports, :ignore_commands,
  #         :optional, :commands, :commands_builder.
  class TestConfigRegistry
    class << self
      # @param test_id [Symbol] test type id from SuiteStructure
      # @param metadata [MetadataManager, nil] required when config uses :commands_builder
      # @return [Hash] config fragment to merge into test_config (title, description, and config; may be empty)
      def config_for(test_id, metadata = nil)
        entry = REGISTRY[test_id]
        return {} if entry.nil?

        out = entry.except(:commands_builder)
        builder = entry[:commands_builder]
        if builder
          built = builder.call(metadata)
          commands = built[:commands]
          out[:commands] = commands if commands
        end
        out
      end

      # @param test_id [Symbol] test type id
      # @return [Boolean] whether this test type has an entry (use for config/title/description).
      #   :bundle_valid is not registered.
      def registered?(test_id)
        REGISTRY.key?(test_id)
      end

      def section_codes_and_elements(metadata, codes_method)
        section_codes = metadata.public_send(codes_method).map { |section| section[:code] }
        elements = mandatory_ms_expressions(metadata)
        [section_codes, elements]
      end

      def mandatory_ms_expressions(metadata)
        ms_elements = metadata.composition_sections.first[:ms_elements]
        positive = ms_elements.filter { |el| el[:min].positive? }
        positive.map { |el| el[:expression] }
      end
    end
  end
end

require_relative 'test_config_registry/entries'
