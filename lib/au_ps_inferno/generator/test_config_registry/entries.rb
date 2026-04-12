# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class Generator
  # Static REGISTRY hash for test type metadata; see TestConfigRegistry in test_config_registry.rb.
  class TestConfigRegistry
    class << self
      REGISTRY = {
        bundle_must_support_populated: {
          title: 'AU PS Bundle Must Support elements are correctly populated',
          description: 'Must Support elements SHALL be populated when an element value is known and allowed ' \
                       'to share.',
          commands: ['bundle_mandatory_ms_elements_info']
        },
        composition_mandatory_ms_populated: {
          title: 'Mandatory Must Support elements are correctly populated',
          description: 'Mandatory Must Support element SHALL be able to be populated if a value is known and ' \
                       'allowed to share.',
          commands_builder: lambda { |m|
            { commands: ["validate_populated_elements_in_composition(#{m.composition_mandatory_ms_elements})"] }
          }
        },
        composition_optional_ms_populated: {
          title: 'Optional Must Support elements are correctly populated',
          description: 'Optional Must Support elements SHALL be correctly populated if a value is known',
          commands_builder: lambda { |m|
            cmd = 'validate_populated_elements_in_composition(' \
                  "#{m.composition_optional_ms_elements}, required: false)"
            { commands: [cmd] }
          }
        },
        composition_ms_subelements_populated: {
          title: 'Must Support sub-elements of a complex element are correctly populated',
          description: 'Must Support sub-elements of a complex element SHALL be correctly populated if a value ' \
                       'is known',
          commands_builder: lambda { |m|
            cmd = 'validate_populated_sub_elements_in_composition(' \
                  "#{m.composition_mandatory_ms_sub_elements}, #{m.composition_optional_ms_sub_elements})"
            { commands: [cmd] }
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
        sections_entry_profiles: {
          title: 'AU PS Composition Mandatory Sections capable of populating referenced profiles',
          description: 'Mandatory section SHALL be capable of populating section.entry with the referenced ' \
                       'profiles and SHOULD correctly populate section.entry if a value is known.',
          commands: ['read_composition_sections_info']
        },
        subject_resource_type_is_valid: {
          title: 'Subject reference in the AU PS Composition SHALL resolve to a valid resource type (Patient).',
          description: 'Subject reference in the AU PS Composition SHALL resolve to a valid resource type (Patient).',
          commands: ['test_resource_type_is_valid?("subject")']
        },
        subject_ms_elements: {
          title: 'Must Support elements SHALL be populated if a value is known',
          description: 'Must Support elements SHALL be populated if a value is known',
          commands: ['ms_elements_populated_message("subject")']
        },
        subject_ms_subelements_populated: {
          title: 'Must Support sub-element SHALL be populated if a value is known and the parent is populated',
          description: 'Must Support sub-element SHALL be populated if a value is known and the parent is populated',
          commands: ['ms_sub_elements_populated_message("subject")']
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
          title: 'Must Support elements SHALL be populated if a value is known',
          description: 'Must Support elements SHALL be populated if a value is known',
          commands: ['ms_elements_populated_message("author")']
        },
        author_ms_subelements: {
          title: 'Must Support sub-elements SHALL be populated if a value is known',
          description: 'Must Support sub-elements SHALL be populated if a value is known',
          commands: ['ms_sub_elements_populated_message("author")']
        },
        author_ms_identifier_slices: {
          title: 'Must Support identifier slices SHALL be populated if a value is known',
          description: 'Must Support identifier slices SHALL be populated if a value is known',
          commands: ['test_composition_author_ms_identifier_slices']
        },
        custodian_ms_elements: {
          title: 'Must Support element SHALL be populated if a value is known',
          description: 'Must Support element SHALL be populated if a value is known',
          commands: ['ms_elements_populated_message("custodian")']
        },
        custodian_ms_subelements: {
          title: 'Must Support sub-element SHALL be populated if a value is known',
          description: 'Must Support sub-element SHALL be populated if a value is known',
          commands: ['ms_sub_elements_populated_message("custodian")']
        },
        custodian_ms_identifier_slices: {
          title: 'Must Support identifier slices SHALL be populated if a value is known',
          description: 'Must Support identifier slices SHALL be populated if a value is known',
          commands: ['test_composition_custodian_ms_identifier_slices']
        },
        attester_party_ms_elements: {
          title: 'Must Support elements SHALL be populated if a value is known',
          description: 'Must Support elements SHALL be populated if a value is known',
          commands: ['ms_elements_populated_message("attester")']
        },
        attester_party_ms_subelements: {
          title: 'Must Support sub-element SHALL be populated if a value is known',
          description: 'Must Support sub-element SHALL be populated if a value is known',
          commands: ['ms_sub_elements_populated_message("attester")']
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
