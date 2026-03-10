# frozen_string_literal: true

class Generator
  # Registry of test type metadata and config keyed by symbol id.
  # Single source of truth for title, description, and config (base_class, commands, etc.).
  # Add new test types here: add an entry keyed by symbol with title:, description:, and optional config.
  # :bundle_valid is not in the registry; its title/description/config come from high-order config in SuiteStructure.
  #
  # Keys: Symbol test type id (e.g. :bundle_must_support_populated).
  # Values: hash with :title, :description, and optional :base_class_name, :imports, :ignore_commands,
  #         :optional, :commands, :commands_builder.
  # rubocop:disable Metrics/ClassLength
  class TestConfigRegistry
    class << self
      # @param test_id [Symbol] test type id from SuiteStructure
      # @param metadata [MetadataManager, nil] required when config uses :commands_builder
      # @return [Hash] config fragment to merge into test_config (title, description, and config; may be empty)
      def config_for(test_id, metadata = nil)
        entry = REGISTRY[test_id]
        return {} if entry.nil?

        out = entry.except(:commands_builder)
        if entry[:commands_builder]
          built = entry[:commands_builder].call(metadata)
          out[:commands] = built[:commands] if built[:commands]
        end
        out
      end

      # @param test_id [Symbol] test type id
      # @return [Boolean] whether this test type has an entry (use for config/title/description).
      #   :bundle_valid is not registered.
      def registered?(test_id)
        REGISTRY.key?(test_id)
      end

      def self.section_codes_and_elements(metadata, codes_method)
        section_codes = metadata.public_send(codes_method).map { |s| s[:code] }
        mandatory_elements = metadata.composition_sections.first[:ms_elements].filter { |el| el[:min].positive? }
        elements = mandatory_elements.map { |el| el[:expression] }
        [section_codes, elements]
      end
      private_class_method :section_codes_and_elements

      REGISTRY = {
        bundle_must_support_populated: {
          title: 'AU PS Bundle Must Support elements are correctly populated',
          description: 'Must Support elements SHALL be populated when an element value is known and allowed to share.',
          commands: ['bundle_mandatory_ms_elements_info']
        },
        composition_mandatory_ms_populated: {
          title: 'Mandatory Must Support elements are correctly populated',
          description: 'Mandatory Must Support element SHALL be able to be populated if a value is known ' \
                       'and allowed to share.',
          commands_builder: lambda { |m|
            { commands: ["validate_populated_elements_in_composition(#{m.composition_mandatory_ms_elements})"] }
          }
        },
        composition_optional_ms_populated: {
          title: 'Optional Must Support elements are correctly populated',
          description: 'Optional Must Support elements SHALL be correctly populated if a value is known',
          commands_builder: lambda { |m|
            cmd = "validate_populated_elements_in_composition(#{m.composition_optional_ms_elements}, required: false)"
            { commands: [cmd] }
          }
        },
        composition_ms_subelements_populated: {
          title: 'Must Support sub-elements of a complex element are correctly populated',
          description: 'Must Support sub-elements of a complex element SHALL be correctly populated ' \
                       'if a value is known',
          commands_builder: lambda { |m|
            args = "#{m.composition_mandatory_ms_sub_elements}, #{m.composition_optional_ms_sub_elements}"
            { commands: ["validate_populated_sub_elements_in_composition(#{args})"] }
          }
        },
        composition_optional_ms_slices: {
          title: 'Must Support slices are correctly populated',
          description: 'Must Support slice careProvisioningEvent SHALL be populated if a value is known.',
          commands_builder: lambda { |m|
            { commands: ["validate_populated_slices_in_composition(#{m.composition_optional_ms_slices})"] }
          }
        },
        sections_shall_populated: {
          title: 'AU PS Composition Mandatory Sections are correctly populated',
          description: 'Mandatory section SHALL be correctly populated if a value is known',
          commands_builder: lambda { |m|
            section_codes, elements = section_codes_and_elements(m, :required_sections_data_codes)
            { commands: ["validate_populated_sections_in_bundle(#{section_codes}, #{elements})"] }
          }
        },
        sections_should_populated: {
          title: 'AU PS Composition recommended sections are correctly populated',
          description: 'Recommended sections SHOULD be correctly populated if a value is known',
          commands_builder: lambda { |m|
            section_codes, elements = section_codes_and_elements(m, :recommended_sections_data_codes)
            { commands: ["validate_populated_sections_in_bundle(#{section_codes}, #{elements}, optional: true)"] }
          }
        },
        sections_may_populated: {
          title: 'AU PS Composition optional sections are correctly populated',
          description: 'Optional section MAY be correctly populated if a value is known',
          commands_builder: lambda { |m|
            section_codes, elements = section_codes_and_elements(m, :optional_sections_data_codes)
            { commands: ["validate_populated_sections_in_bundle(#{section_codes}, #{elements}, optional: true)"] }
          }
        },
        sections_may_undefined: {
          title: 'Undefined sections are correctly populated',
          description: 'Undefined sections MAY be populated if a value is known',
          commands_builder: lambda { |m|
            section_codes = m.all_sections_data_codes
            mandatory_el = m.composition_sections.first[:ms_elements].filter { |el| el[:min].positive? }
            elements = mandatory_el.map { |el| el[:expression] }
            { commands: ["validate_populated_undefined_sections_in_bundle(#{section_codes}, #{elements})"] }
          }
        },
        sections_entry_profiles: {
          title: 'AU PS Composition Mandatory Sections capable of populating referenced profiles',
          description: 'Mandatory section SHALL be capable of populating section.entry with the referenced ' \
                       'profiles and SHOULD correctly populate section.entry if a value is known.',
          commands_builder: lambda { |m|
            sections_data = m.composition_sections.filter { |s| s[:required] == true && s[:mustSupport] == true }
            { commands: ["read_composition_sections_info(#{sections_data}, #{m.return_normalized_sections_data})"] }
          }
        },
        subject_ms_elements: {
          title: 'Must Support elements SHALL be populated if a value is known',
          description: 'Must Support elements SHALL be populated if a value is known',
          commands: ['test_subject_ms_elements']
        },
        subject_ms_subelements_populated: {
          title: 'Must Support sub-element SHALL be populated if a value is known and the parent is populated',
          description: 'Must Support sub-element SHALL be populated if a value is known and the parent is populated',
          commands: ['test_subject_ms_subelements_when_parent_populated']
        },
        subject_ms_identifier_slices: {
          title: 'Must Support identifier slices SHALL be populated if a value is known',
          description: 'Must Support identifier slices SHALL be populated if a value is known ' \
                       '(i.e. ihi, dva, medicare).',
          commands: ['test_subject_ms_identifier_slices']
        },
        author_ms_elements: {
          title: 'Must Support elements SHALL be populated if a value is known',
          description: 'Must Support elements SHALL be populated if a value is known',
          commands: ['test_composition_author_ms_elements']
        },
        author_ms_subelements: {
          title: 'Must Support sub-elements SHALL be populated if a value is known',
          description: 'Must Support sub-elements SHALL be populated if a value is known',
          commands: ['test_composition_author_ms_subelements']
        },
        author_ms_identifier_slices: {
          title: 'Must Support identifier slices SHALL be populated if a value is known',
          description: 'Must Support identifier slices SHALL be populated if a value is known',
          commands: ['test_composition_author_ms_identifier_slices']
        },
        custodian_ms_elements: {
          title: 'Must Support element SHALL be populated if a value is known',
          description: 'Must Support element SHALL be populated if a value is known',
          commands: ['test_composition_custodian_ms_elements']
        },
        custodian_ms_subelements: {
          title: 'Must Support sub-element SHALL be populated if a value is known',
          description: 'Must Support sub-element SHALL be populated if a value is known',
          commands: ['test_composition_custodian_ms_subelements']
        },
        custodian_ms_identifier_slices: {
          title: 'Must Support identifier slices SHALL be populated if a value is known',
          description: 'Must Support identifier slices SHALL be populated if a value is known',
          commands: ['test_composition_custodian_ms_identifier_slices']
        },
        attester_party_ms_elements: {
          title: 'Must Support elements SHALL be populated if a value is known',
          description: 'Must Support elements SHALL be populated if a value is known',
          commands: ['test_composition_attester_party_ms_elements']
        },
        attester_party_ms_subelements: {
          title: 'Must Support sub-element SHALL be populated if a value is known',
          description: 'Must Support sub-element SHALL be populated if a value is known',
          commands: ['test_composition_attester_party_ms_subelements']
        },
        attester_party_ms_identifier_slices: {
          title: 'Must Support identifier slices SHALL be populated if a value is known',
          description: 'Must Support identifier slices SHALL be populated if a value is known',
          commands: ['test_composition_attester_party_ms_identifier_slices']
        }
      }.freeze
    end
  end
  # rubocop:enable Metrics/ClassLength
end
