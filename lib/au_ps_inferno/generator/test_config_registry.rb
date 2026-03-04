# frozen_string_literal: true

class Generator
  # Registry of test configurations keyed by test title.
  # Add new test types here instead of extending the Generator case statement.
  #
  # Keys: exact test title string as in SuiteStructure.
  # Values: hash to merge into primitive test config. Use :commands_builder => lambda { |metadata| [...] }
  # for commands that depend on metadata; use :commands => [...] for static commands.
  # Optional keys: :base_class_name, :imports, :ignore_commands, :optional.
  class TestConfigRegistry
    class << self
      # @param test_name [String]
      # @param metadata [MetadataManager, nil] required when config uses :commands_builder
      # @return [Hash] config fragment to merge into test_config (may be empty)
      def config_for(test_name, metadata = nil)
        entry = REGISTRY[test_name]
        return {} if entry.nil?

        out = entry.except(:commands_builder)
        if entry[:commands_builder]
          built = entry[:commands_builder].call(metadata)
          out[:commands] = built[:commands] if built[:commands]
        end
        out
      end

      # @param test_name [String]
      # @return [Boolean] whether this test has custom config (so we use it instead of default BasicTest)
      def registered?(test_name)
        REGISTRY.key?(test_name)
      end

      def self.section_codes_and_elements(metadata, codes_method)
        section_codes = metadata.public_send(codes_method).map { |s| s[:code] }
        elements = metadata.composition_sections.first[:ms_elements].filter do |el|
          el[:min].positive?
        end.map { |el| el[:expression] }
        [section_codes, elements]
      end
      private_class_method :section_codes_and_elements

      REGISTRY = {
        'Bundle is valid against AU PS Bundle profile' => {
          description: 'Verifies that the bundle conforms to the AU PS Bundle profile.',
          base_class_name: 'BundleIsValidClass',
          imports: ['../../../utils/bundle_is_valid_class'],
          ignore_commands: true
        },
        'Retrieved Bundle is valid against AU PS Bundle profile' => {
          description: 'Verifies that a bundle retrieved from the server conforms to the AU PS Bundle profile.',
          base_class_name: 'RetrieveBundleTestClass',
          imports: ['../../../utils/retrieve_bundle_test_class'],
          ignore_commands: true
        },
        'Generated Bundle is valid against AU PS Bundle profile' => {
          description: 'Verifies that a bundle produced by the IPS $summary operation conforms to the AU PS Bundle profile.',
          base_class_name: 'SummaryValidBundleClass',
          imports: ['../../../utils/summary_valid_bundle_class'],
          ignore_commands: true
        },
        'Must Support elements SHALL be populated when an element value is known and allowed to share' => {
          description: 'Verifies that bundle-level Must Support elements are populated when data is available and shareable.',
          commands: ['bundle_mandatory_ms_elements_info']
        },
        'Mandatory Must Support element SHALL be able to be populated if a value is known and allowed to share' => {
          description: 'Verifies that mandatory Must Support elements in the Composition can be populated when data is known and shareable.',
          commands_builder: lambda { |m|
            { commands: ["validate_populated_elements_in_composition(#{m.composition_mandatory_ms_elements})"] }
          }
        },
        'Optional Must Support elements SHALL be correctly populated if a value is known' => {
          description: 'Verifies that optional Must Support elements in the Composition are correctly populated when data is known.',
          commands_builder: lambda { |m|
            { commands: ["validate_populated_elements_in_composition(#{m.composition_optional_ms_elements})"] }
          },
          optional: true
        },
        'Must Support sub-elements of a complex element SHALL be correctly populated if a value is known' => {
          description: 'Verifies that Must Support sub-elements of complex elements are correctly populated when data is known.',
          commands_builder: lambda { |m|
            { commands: ["validate_populated_elements_in_composition(#{m.composition_optional_ms_sub_elements})"] }
          },
          optional: true
        },
        'Optional Must Support slices SHALL be populated if a value is known' => {
          description: 'Verifies that optional Must Support slices are populated when data is known.',
          commands_builder: lambda { |m|
            { commands: ["validate_populated_slices_in_composition(#{m.composition_optional_ms_slices})"] }
          },
          optional: true
        },
        'Sections SHALL be correctly populated if a value is known' => {
          description: 'Verifies that mandatory sections are correctly populated when data is known.',
          commands_builder: lambda { |m|
            section_codes, elements = section_codes_and_elements(m, :required_sections_data_codes)
            { commands: ["validate_populated_sections_in_bundle(#{section_codes}, #{elements})"] }
          }
        },
        'Sections SHOULD be correctly populated if a value is known' => {
          description: 'Verifies that recommended sections are correctly populated when data is known.',
          commands_builder: lambda { |m|
            section_codes, elements = section_codes_and_elements(m, :recommended_sections_data_codes)
            { commands: ["validate_populated_sections_in_bundle(#{section_codes}, #{elements})"] }
          },
          optional: true
        },
        'Sections MAY be correctly populated if a value is known' => {
          description: 'Verifies that optional sections are correctly populated when data is known.',
          commands_builder: lambda { |m|
            section_codes, elements = section_codes_and_elements(m, :optional_sections_data_codes)
            { commands: ["validate_populated_sections_in_bundle(#{section_codes}, #{elements})"] }
          },
          optional: true
        },
        'Sections MAY be populated' => {
          description: 'Verifies that undefined sections may be populated without violating conformance.',
          commands_builder: lambda { |m|
            section_codes = m.all_sections_data_codes
            elements = m.composition_sections.first[:ms_elements].filter do |el|
              el[:min].positive?
            end.map { |el| el[:expression] }
            { commands: ["validate_populated_undefined_sections_in_bundle(#{section_codes}, #{elements})"] }
          },
          optional: true
        },
        'Sections SHALL be capable of populating section.entry with the referenced profiles, and SHOULD correctly populate section.entry if a value is known' => {
          description: 'Verifies that mandatory sections can reference the required profiles in section.entry and that entries are populated when data is known.',
          commands_builder: lambda { |m|
            sections_data = m.composition_sections.filter { |s| s[:required] == true && s[:mustSupport] == true }
            { commands: ["read_composition_sections_info(#{sections_data}, #{m.return_normalized_sections_data})"] }
          }
        }
      }.freeze
    end
  end
end
