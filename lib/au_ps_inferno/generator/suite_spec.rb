# frozen_string_literal: true

require_relative 'metadata_manager'

class Generator
  # Static description of the suite shape rendered by {SuiteFileGenerator} for a new IG version.
  #
  # The shape mirrors the hand-authored `lib/au_ps_inferno/suite/` tree (the 1.0.0 suite) exactly:
  # three "flavors" (bundle_static / bundle_retrieval / ips_summary), each wrapping the same eleven
  # primitive groups, each with a small number of leaf tests whose bodies are a single call into a
  # shared `BasicTest` helper method. Arguments that depend on IG data (section codes, must-support
  # element paths, slices, profiles) are supplied as procs that receive the generation-time
  # {MetadataManager} instance and return the literal Ruby source for the call.
  #
  # `lib/au_ps_inferno/suite/` itself is never read or written by this module - it only describes
  # the shape new versions should take.
  module SuiteSpec
    # One entry per high-order group ("flavor"). `bundle_valid`/`bundle_valid_ips` describe the one
    # leaf pair whose title/description/base class differ per flavor - the Bundle Validation group
    # is otherwise identical across flavors.
    FLAVORS = [
      {
        id: 'bundle_static',
        title: 'AU PS Bundle Instance',
        description: 'Validates a static AU PS bundle instance for profile conformance, Must Support ' \
                     'elements, and composition sections.',
        bundle_valid: {
          title: 'Bundle is valid against AU PS Bundle',
          description: 'The Bundle resource is valid against the AU PS Bundle profile using FHIR validator',
          base_class: 'BundleIsValidClass'
        },
        bundle_valid_ips: {
          title: 'Bundle is valid against IPS Bundle',
          description: 'The Bundle resource is valid against the IPS Bundle profile using FHIR validator',
          base_class: 'IpsBundleIsValidClass'
        },
        bundle_validation_requires: %w[bundle_is_valid_class ips_bundle_is_valid_class]
      },
      {
        id: 'bundle_retrieval',
        title: 'Retrieve AU PS Bundle validation tests',
        description: 'Retrieve document Bundle using Bundle read interaction or other HTTP GET request ' \
                     'and verify response is valid AU PS Bundle',
        bundle_valid: {
          title: 'Retrieved Bundle is valid against AU PS Bundle profile',
          description: 'Verifies that a bundle retrieved from the server conforms to the AU PS Bundle profile.',
          base_class: 'RetrieveBundleTestClass'
        },
        bundle_valid_ips: {
          title: 'Retrieved Bundle is valid against IPS Bundle profile',
          description: 'Verifies that a bundle retrieved from the server conforms to the IPS Bundle profile.',
          base_class: 'IpsRetrieveBundleTestClass'
        },
        bundle_validation_requires: %w[retrieve_bundle_test_class ips_retrieve_bundle_test_class]
      },
      {
        id: 'ips_summary',
        title: 'Generate AU PS using IPS $summary validation tests',
        description: 'Generate AU Patient Summary using IPS $summary operation and verify response is ' \
                     'valid AU PS Bundle',
        bundle_valid: {
          title: 'Generated Bundle is valid against AU PS Bundle profile',
          description: 'Verifies that a bundle produced by the IPS $summary operation conforms to the ' \
                       'AU PS Bundle profile.',
          base_class: 'SummaryValidBundleClass'
        },
        bundle_valid_ips: {
          title: 'Generated Bundle is valid against IPS Bundle profile',
          description: 'Verifies that a bundle produced by the IPS $summary operation conforms to the ' \
                       'IPS Bundle profile.',
          base_class: 'IpsSummaryValidBundleClass'
        },
        bundle_validation_requires: %w[summary_valid_bundle_class ips_summary_valid_bundle_class]
      }
    ].freeze

    # Sections whose composition-level metadata flags them as required (min > 0).
    def self.mandatory_section_codes(metadata)
      metadata.composition_sections.select { |s| s[:required] }.map { |s| s[:code] }
    end

    def self.recommended_section_codes(_metadata)
      MetadataManager::RECOMMENDED_SECTIONS_CODES
    end

    def self.optional_section_codes(_metadata)
      MetadataManager::OPTIONAL_SECTIONS_CODES
    end

    def self.all_section_codes(metadata)
      mandatory_section_codes(metadata) + recommended_section_codes(metadata) + optional_section_codes(metadata)
    end

    # The eleven primitive groups nested under every flavor. Each group's `key` and every leaf's
    # `key` are short, non-redundant suffixes - the generator concatenates
    # "<flavor_id>_<group.key>_<leaf.key>" to build the final id/file basename, so keys deliberately
    # avoid repeating words already contributed by an outer key to stay well under the 95-byte tar
    # basename cap enforced by spec/unit/suite_file_name_length_spec.rb.
    PRIMITIVE_GROUPS = [
      {
        key: 'bundle_ms',
        title: 'AU PS Bundle Must Support Conformance',
        description: 'Verifies that Must Support elements at the bundle level are populated when data is available.',
        leaves: [
          { key: 'populated',
            title: 'AU PS Bundle Must Support elements are correctly populated',
            description: 'Must Support elements SHALL be populated when an element value is known and ' \
                         'allowed to share.',
            call: ->(_md) { 'bundle_mandatory_ms_elements_info' } }
        ]
      },
      {
        key: 'composition_ms',
        title: 'AU PS Composition Must Support Conformance',
        description: 'Verifies that Composition Must Support elements (mandatory, optional, sub-elements, ' \
                     'slices) are correctly populated when data is known.',
        leaves: [
          { key: 'mandatory_populated',
            title: 'Mandatory Must Support elements are correctly populated',
            description: 'Mandatory Must Support element SHALL be able to be populated if a value is ' \
                         'known and allowed to share.',
            call: lambda { |md|
              "validate_populated_elements_in_composition(#{md.composition_mandatory_ms_elements.inspect})"
            } },
          { key: 'optional_populated',
            title: 'Optional Must Support elements are correctly populated',
            description: 'Optional Must Support elements SHALL be correctly populated if a value is known',
            call: lambda { |md|
              "validate_populated_elements_in_composition(#{md.composition_optional_ms_elements.inspect}, " \
                'required: false)'
            } },
          { key: 'subelements_populated',
            title: 'Must Support sub-elements of a complex element are correctly populated',
            description: 'Must Support sub-elements of a complex element SHALL be correctly populated if ' \
                         'a value is known',
            call: lambda { |md|
              "validate_populated_sub_elements_in_composition(#{md.composition_mandatory_ms_sub_elements.inspect}, " \
                "#{md.composition_optional_ms_sub_elements.inspect})"
            } },
          { key: 'mandatory_slices',
            title: 'Mandatory Must Support slices are correctly populated',
            description: 'Mandatory Must Support slice(s) SHALL be populated if a value is known.',
            condition: ->(md) { md.composition_mandatory_ms_slices.any? },
            call: lambda { |md|
              "validate_populated_slices_in_composition(#{md.composition_mandatory_ms_slices.inspect})"
            } },
          { key: 'optional_slices',
            title: 'Must Support slices are correctly populated',
            description: 'Optional Must Support slice(s) SHALL be populated if a value is known.',
            condition: ->(md) { md.composition_optional_ms_slices.any? },
            call: lambda { |md|
              "validate_populated_slices_in_composition(#{md.composition_optional_ms_slices.inspect})"
            } }
        ]
      },
      {
        key: 'mandatory_sections',
        title: 'AU PS Composition Mandatory Sections',
        description: 'Verify the mandatory sections are correctly populated in the AU PS Composition resource',
        leaves: [
          { key: 'populated',
            title: 'AU PS Composition Mandatory Sections are correctly populated',
            description: 'Mandatory section SHALL be correctly populated if a value is known',
            call: lambda { |md|
              "validate_populated_sections_in_bundle(#{SuiteSpec.mandatory_section_codes(md).inspect}, " \
                '%w[title code text])'
            } },
          { key: 'entry_profiles',
            title: 'AU PS Composition Mandatory Sections capable of populating referenced profiles',
            description: 'Mandatory section SHALL be capable of populating section.entry with the ' \
                         'referenced profiles and SHOULD correctly populate section.entry if a value is known.',
            call: ->(_md) { 'test_composition_mandatory_sections' } }
        ]
      },
      {
        key: 'recommended_sections',
        title: 'AU PS Composition Recommended Sections',
        description: 'Verify the recommended sections are correctly populated in the Composition resource',
        leaves: [
          { key: 'populated',
            title: 'AU PS Composition recommended sections are correctly populated',
            description: 'Recommended sections SHOULD be correctly populated if a value is known',
            call: lambda { |md|
              "validate_populated_sections_in_bundle(#{SuiteSpec.recommended_section_codes(md).inspect}, " \
                '%w[title code text], optional: true)'
            } },
          { key: 'entry_profiles',
            title: 'AU PS Composition Recommended Sections capable of populating referenced profiles',
            description: 'Recommended section SHALL be capable of populating section.entry with the ' \
                         'referenced profiles and SHOULD correctly populate section.entry if a value is known.',
            call: ->(_md) { 'test_composition_recommended_sections' } }
        ]
      },
      {
        key: 'optional_sections',
        title: 'AU PS Composition Optional Sections',
        description: 'Verify the optional sections are correctly populated in the AU PS Composition resource',
        leaves: [
          { key: 'populated',
            title: 'AU PS Composition optional sections are correctly populated',
            description: 'Optional section MAY be correctly populated if a value is known',
            call: lambda { |md|
              "validate_populated_sections_in_bundle(#{SuiteSpec.optional_section_codes(md).inspect}, " \
                '%w[title code text], optional: true)'
            } },
          { key: 'entry_profiles',
            title: 'AU PS Composition Optional Sections capable of populating referenced profiles',
            description: 'Optional section SHALL be capable of populating section.entry with the ' \
                         'referenced profiles and SHOULD correctly populate section.entry if a value is known.',
            optional_test: true,
            call: ->(_md) { 'test_composition_optional_sections' } }
        ]
      },
      {
        key: 'undefined_sections',
        title: 'AU PS Composition Undefined Sections',
        description: 'Verify the undefined sections are correctly populated in the AU PS Composition resource.',
        optional_group: true,
        leaves: [
          { key: 'populated',
            title: 'Undefined sections are correctly populated',
            description: 'Undefined sections MAY be populated if a value is known',
            call: lambda { |md|
              "validate_populated_undefined_sections_in_bundle(#{SuiteSpec.all_section_codes(md).inspect}, " \
                '%w[title code text])'
            } }
        ]
      },
      {
        key: 'subject',
        title: 'AU PS Composition Subject',
        description: 'Verify the referenced subject is a correctly populated AU PS Patient resource.',
        leaves: [
          { key: 'resource_type_valid',
            title: 'Subject reference in the AU PS Composition SHALL resolve to a valid resource type (Patient).',
            description: 'Subject reference in the AU PS Composition SHALL resolve to a valid resource ' \
                         'type (Patient).',
            call: ->(_md) { "test_resource_type_is_valid?('subject')" } },
          { key: 'ms_elements',
            title: 'Must Support elements SHALL be populated if a value is known',
            description: 'Must Support elements SHALL be populated if a value is known',
            call: ->(_md) { "ms_elements_populated_message('subject')" } },
          { key: 'ms_subelements',
            title: 'Must Support sub-element SHALL be populated if a value is known and the parent is populated',
            description: 'Must Support sub-element SHALL be populated if a value is known and the ' \
                         'parent is populated',
            call: ->(_md) { "ms_sub_elements_populated_message('subject')" } },
          { key: 'ms_identifier_slices',
            title: 'Must Support identifier slices SHALL be populated if a value is known',
            description: 'Must Support identifier slices SHALL be populated if a value is known ' \
                         '(i.e. ihi, dva, medicare).',
            call: ->(_md) { 'test_subject_ms_identifier_slices' } }
        ]
      },
      {
        key: 'author',
        title: 'AU PS Composition Author',
        description: 'Verify the referenced author is a correctly populated AU PS Practitioner, AU PS ' \
                     'PractitionerRole, AU PS Patient, AU PS RelatedPerson, AU PS Organization profiles ' \
                     'or Device resource.',
        leaves: [
          { key: 'resource_type_valid',
            title: 'Author reference in the AU PS Composition SHALL resolve to a valid resource type ' \
                   '(Practitioner, PractitionerRole, Device, Patient, RelatedPerson, Organization).',
            description: 'Author reference in the AU PS Composition SHALL resolve to a valid resource ' \
                         'type (Practitioner, PractitionerRole, Device, Patient, RelatedPerson, Organization).',
            call: ->(_md) { "test_resource_type_is_valid?('author')" } },
          { key: 'ms_elements',
            title: 'Must Support elements SHALL be populated if a value is known',
            description: 'Must Support elements SHALL be populated if a value is known',
            call: ->(_md) { "ms_elements_populated_message('author')" } },
          { key: 'ms_subelements',
            title: 'Must Support sub-elements SHALL be populated if a value is known',
            description: 'Must Support sub-elements SHALL be populated if a value is known',
            call: ->(_md) { "ms_sub_elements_populated_message('author')" } },
          { key: 'ms_identifier_slices',
            title: 'Must Support identifier slices SHALL be populated if a value is known',
            description: 'Must Support identifier slices SHALL be populated if a value is known',
            call: ->(_md) { 'test_composition_author_ms_identifier_slices' } }
        ]
      },
      {
        key: 'custodian',
        title: 'AU PS Composition Custodian',
        description: 'Verify the referenced custodian is a correctly populated AU PS Organization resource.',
        optional_group: true,
        leaves: [
          { key: 'ms_elements',
            title: 'Must Support element SHALL be populated if a value is known',
            description: 'Must Support element SHALL be populated if a value is known',
            call: ->(_md) { "ms_elements_populated_message('custodian')" } },
          { key: 'ms_subelements',
            title: 'Must Support sub-element SHALL be populated if a value is known',
            description: 'Must Support sub-element SHALL be populated if a value is known',
            call: ->(_md) { "ms_sub_elements_populated_message('custodian')" } },
          { key: 'ms_identifier_slices',
            title: 'Must Support identifier slices SHALL be populated if a value is known',
            description: 'Must Support identifier slices SHALL be populated if a value is known',
            call: ->(_md) { 'test_composition_custodian_ms_identifier_slices' } }
        ]
      },
      {
        key: 'attester',
        title: 'AU PS Composition Attester',
        description: 'Verify the referenced attester.party is a correctly populated AU PS Patient, ' \
                     'RelatedPerson, Practitioner, PractitionerRole, or Organization resource.',
        optional_group: true,
        leaves: [
          { key: 'ms_elements',
            title: 'Must Support elements SHALL be populated if a value is known',
            description: 'Must Support elements SHALL be populated if a value is known',
            call: ->(_md) { "ms_elements_populated_message('attester')" } },
          { key: 'ms_subelements',
            title: 'Must Support sub-element SHALL be populated if a value is known',
            description: 'Must Support sub-element SHALL be populated if a value is known',
            call: ->(_md) { "ms_sub_elements_populated_message('attester')" } },
          { key: 'ms_identifier_slices',
            title: 'Must Support identifier slices SHALL be populated if a value is known',
            description: 'Must Support identifier slices SHALL be populated if a value is known',
            call: ->(_md) { 'test_composition_attester_party_ms_identifier_slices' } }
        ]
      }
    ].freeze
  end
end
