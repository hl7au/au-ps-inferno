# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class Generator
  # Static REGISTRY hash for test type metadata; see TestConfigRegistry in test_config_registry.rb.
  class TestConfigRegistry
    class << self
      REGISTRY = {
        bundle_must_support_populated: {
          title: 'AU PS Bundle Must Support elements are correctly populated',
          description: 'Must Support elements SHALL be included if a value is known and allowed to be shared.',
          commands: ['bundle_mandatory_ms_elements_info']
        },
        composition_must_support_populated: {
          title: 'Composition Must Support elements are correctly populated',
          description: 'Composition Must Support elements — mandatory and optional elements, sub-elements ' \
                       'of complex elements, and the careProvisioningEvent slice — SHALL be populated if a ' \
                       'value is known and allowed to be shared.',
          commands_builder: lambda { |m|
            cmd = 'validate_composition_must_support(' \
                  "#{m.composition_mandatory_ms_elements}, #{m.composition_optional_ms_elements}, " \
                  "#{m.composition_mandatory_ms_sub_elements}, #{m.composition_optional_ms_sub_elements}, " \
                  "#{m.composition_optional_ms_slices})"
            { commands: [cmd] }
          }
        },
        sections_shall_populated: {
          title: 'AU PS Composition Mandatory Sections are correctly populated',
          description: 'Mandatory section SHALL be correctly populated if a value is known',
          commands_builder: lambda { |m|
            section_codes, elements = TestConfigRegistry.section_codes_and_elements(
              m, :required_sections_data_codes
            )
            { commands: ["validate_populated_sections_in_bundle(#{section_codes}, #{elements})"] }
          }
        },
        sections_should_populated: {
          title: 'AU PS Composition recommended sections are correctly populated',
          description: 'Recommended sections SHOULD be correctly populated if a value is known',
          commands_builder: lambda { |m|
            section_codes, elements = TestConfigRegistry.section_codes_and_elements(
              m, :recommended_sections_data_codes
            )
            { commands: ["validate_populated_sections_in_bundle(#{section_codes}, #{elements}, optional: true)"] }
          }
        },
        sections_may_populated: {
          title: 'AU PS Composition optional sections are correctly populated',
          description: 'Optional section MAY be correctly populated if a value is known',
          commands_builder: lambda { |m|
            section_codes, elements = TestConfigRegistry.section_codes_and_elements(
              m, :optional_sections_data_codes
            )
            { commands: ["validate_populated_sections_in_bundle(#{section_codes}, #{elements}, optional: true)"] }
          }
        },
        sections_may_undefined: {
          title: 'Undefined sections are correctly populated',
          description: 'Undefined sections MAY be populated if a value is known',
          commands_builder: lambda { |m|
            section_codes = m.all_sections_data_codes
            elements = TestConfigRegistry.mandatory_ms_expressions(m)
            { commands: ["validate_populated_undefined_sections_in_bundle(#{section_codes}, #{elements})"] }
          }
        },
        mandatory_sections_entry_profiles: {
          title: 'AU PS Composition Mandatory Sections capable of populating referenced profiles',
          description: 'Mandatory section SHALL be capable of populating section.entry with the referenced ' \
                       'profiles and SHOULD correctly populate section.entry if a value is known.',
          commands: ['test_composition_mandatory_sections']
        },
        recommended_sections_entry_profiles: {
          title: 'AU PS Composition Recommended Sections capable of populating referenced profiles',
          description: 'Recommended section SHALL be capable of populating section.entry with the referenced ' \
                       'profiles and SHOULD correctly populate section.entry if a value is known.',
          commands: ['test_composition_recommended_sections']
        },
        optional_sections_entry_profiles: {
          title: 'AU PS Composition Optional Sections capable of populating referenced profiles',
          description: 'Optional section SHALL be capable of populating section.entry with the referenced ' \
                       'profiles and SHOULD correctly populate section.entry if a value is known.',
          commands: [
            'test_composition_optional_sections'
          ]
        },
        subject_resource_type_is_valid: {
          title: 'Subject reference in the AU PS Composition SHALL resolve to a valid resource type (Patient).',
          description: 'Subject reference in the AU PS Composition SHALL resolve to a valid resource type (Patient).',
          commands: ['test_resource_type_is_valid?("subject")']
        },
        subject_ms_elements: {
          title: 'Must Support elements (including sub-elements) SHALL be populated if a value is known',
          description: 'Must Support elements, including sub-elements of complex elements, SHALL be ' \
                       'populated if a value is known.',
          commands: ['ms_elements_populated_message("subject")']
        },
        subject_ms_identifier_slices: {
          title: 'Must Support identifier slices SHALL be populated if a value is known',
          description: 'Must Support identifier slices SHALL be populated if a value is known ' \
                       '(i.e. ihi, dva, medicare).',
          commands: ['test_subject_ms_identifier_slices']
        },
        author_resource_type_is_valid: {
          title: 'Author reference in the AU PS Composition SHALL resolve to a valid resource type ' \
                 '(Practitioner, PractitionerRole, Device, Patient, RelatedPerson, Organization).',
          description: 'Author reference in the AU PS Composition SHALL resolve to a valid resource type ' \
                       '(Practitioner, PractitionerRole, Device, Patient, RelatedPerson, Organization).',
          commands: ['test_resource_type_is_valid?("author")']
        },
        author_ms_elements: {
          title: 'Must Support elements (including sub-elements) SHALL be populated if a value is known',
          description: 'Must Support elements, including sub-elements of complex elements, SHALL be ' \
                       'populated if a value is known.',
          commands: ['ms_elements_populated_message("author")']
        },
        author_ms_identifier_slices: {
          title: 'Must Support identifier slices SHALL be populated if a value is known',
          description: 'Must Support identifier slices SHALL be populated if a value is known',
          commands: ['test_composition_author_ms_identifier_slices']
        },
        custodian_ms_elements: {
          title: 'Must Support elements (including sub-elements) SHALL be populated if a value is known',
          description: 'Must Support elements, including sub-elements of complex elements, SHALL be ' \
                       'populated if a value is known.',
          commands: ['ms_elements_populated_message("custodian")']
        },
        custodian_ms_identifier_slices: {
          title: 'Must Support identifier slices SHALL be populated if a value is known',
          description: 'Must Support identifier slices SHALL be populated if a value is known',
          commands: ['test_composition_custodian_ms_identifier_slices']
        },
        attester_party_ms_elements: {
          title: 'Must Support elements (including sub-elements) SHALL be populated if a value is known',
          description: 'Must Support elements, including sub-elements of complex elements, SHALL be ' \
                       'populated if a value is known.',
          commands: ['ms_elements_populated_message("attester")']
        },
        attester_party_ms_identifier_slices: {
          title: 'Must Support identifier slices SHALL be populated if a value is known',
          description: 'Must Support identifier slices SHALL be populated if a value is known',
          commands: ['test_composition_attester_party_ms_identifier_slices']
        }
      }.freeze
    end
  end
end
# rubocop:enable Metrics/ClassLength
