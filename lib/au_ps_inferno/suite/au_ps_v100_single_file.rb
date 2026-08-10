# frozen_string_literal: true

require_relative '../version'
require_relative '../utils/basic_test_class'
require_relative '../utils/metadata_manager'
require_relative '../utils/provided_bundle_test_class'
require_relative '../utils/retrieve_bundle_test_class'
require_relative '../utils/generate_summary_bundle_test_class'
require_relative '../utils/bundle_is_valid_class'
require_relative '../utils/ips_bundle_is_valid_class'
require_relative 'au_ps_retrieve_cs_group/au_ps_retrieve_cs_group'

module AUPSTestKit
  class SingleFileBasicTest < BasicTest
    id :single_file_basic_test

    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../metadata.yaml', __dir__))
    end
  end

  class AUPSSuiteSingleFile < Inferno::TestSuite
    id :au_ps_v100_single_file
    title "AU PS #{AUPSTestKit::IG_VERSION} Test Suite (single-file, metaprogrammed)"
    description 'Same structure and test logic as au_ps_v100, built by looping over a small ' \
                'BUNDLE_SOURCES array and calling Inferno\'s `test`/`group` DSL, instead of by ' \
                'requiring ~90 generated files. See docs/single-file-metaprogrammed-suite.md.'

    fhir_resource_validator do
      igs "hl7.fhir.au.ps##{AUPSTestKit::IG_VERSION}"

      cli_context do
        txServer ENV.fetch('TX_SERVER_URL', 'https://tx.dev.hl7.org.au/fhir')
        snomedCT ENV.fetch('SNOMED_EDITION', 'au')
        noEcosystem true
      end
    end

    BUNDLE_SOURCES = [
      {
        top_id: :single_file_au_ps_bundle_instance,
        top_title: 'AU PS Bundle Instance',
        top_description: 'Validates a static AU PS bundle instance for profile conformance, Must Support ' \
                         'elements, and composition sections.',
        acquisition_from: :provided_bundle_test_class,
        acquisition_group_title: 'Provide AU PS Bundle',
        acquisition_group_description: 'Loads the Bundle resource pasted as text and stores it for the ' \
                                       'validation tests in this group.',
        acquisition_test_title: 'Bundle instance is parsable',
        acquisition_test_description: 'The provided text can be parsed as a FHIR resource (JSON or XML) and ' \
                                      'its resourceType is Bundle. The parsed Bundle is stored for the ' \
                                      'validation tests in this group; conformance to the AU PS Bundle profile ' \
                                      'is tested separately under Bundle Validation.',
        bundle_valid_title: 'Bundle is valid against AU PS Bundle',
        bundle_valid_description: 'The Bundle resource is valid against the AU PS Bundle profile using FHIR validator',
        bundle_valid_ips_title: 'Bundle is valid against IPS Bundle',
        bundle_valid_ips_description: 'The Bundle resource is valid against the IPS Bundle profile using FHIR validator'
      },
      {
        top_id: :single_file_retrieve_au_ps_bundle_validation_tests,
        top_title: 'Retrieve AU PS Bundle validation tests',
        top_description: 'Retrieve document Bundle using Bundle read interaction or other HTTP GET request ' \
                         'and verify response is valid AU PS Bundle',
        acquisition_from: :retrieve_bundle_test_class,
        acquisition_group_title: 'Retrieve AU PS Bundle',
        acquisition_group_description: 'Retrieves the document Bundle using a Bundle read interaction or a ' \
                                       'direct HTTP GET request and stores it for the validation tests in this group.',
        acquisition_test_title: 'Bundle is retrievable from the FHIR server',
        acquisition_test_description: 'A Bundle can be retrieved via a Bundle read interaction (FHIR server ' \
                                      'URL and Bundle ID) or a direct HTTP GET of the Bundle URL, returning ' \
                                      'HTTP 200 with a parsable FHIR Bundle. The retrieved Bundle is stored ' \
                                      'for the validation tests in this group.',
        bundle_valid_title: 'Retrieved Bundle is valid against AU PS Bundle profile',
        bundle_valid_description: 'Verifies that the bundle retrieved from the server conforms to the AU PS Bundle profile.',
        bundle_valid_ips_title: 'Retrieved Bundle is valid against IPS Bundle profile',
        bundle_valid_ips_description: 'Verifies that the bundle retrieved from the server conforms to the IPS Bundle profile.'
      },
      {
        top_id: :single_file_generate_au_ps_using_ips_summary_validation_tests,
        top_title: 'Generate AU PS using IPS $summary validation tests',
        top_description: 'Generate AU Patient Summary using IPS $summary operation and verify response is ' \
                         'valid AU PS Bundle',
        acquisition_from: :generate_summary_bundle_test_class,
        acquisition_group_title: 'Generate AU PS Bundle using $summary',
        acquisition_group_description: 'Invokes the IPS $summary operation on the FHIR server and stores the ' \
                                       'returned Bundle for the validation tests in this group.',
        acquisition_test_title: 'Patient summary Bundle is generated by the IPS $summary operation',
        acquisition_test_description: 'The IPS $summary operation returns HTTP 200 with a Bundle. The ' \
                                      'generated Bundle is stored for the validation tests in this group.',
        bundle_valid_title: 'Generated Bundle is valid against AU PS Bundle profile',
        bundle_valid_description: 'Verifies that a bundle produced by the IPS $summary operation conforms to the AU PS Bundle profile.',
        bundle_valid_ips_title: 'Generated Bundle is valid against IPS Bundle profile',
        bundle_valid_ips_description: 'Verifies that a bundle produced by the IPS $summary operation conforms to the IPS Bundle profile.'
      }
    ].freeze

    SECTION_TIERS = [
      {
        group_id: :au_ps_composition_mandatory_sections,
        group_title: 'AU PS Composition Mandatory Sections',
        group_description: 'Verify the mandatory sections are correctly populated in the AU PS Composition resource',
        codes: %w[11450-4 48765-2 10160-0],
        populated_optional: false,
        populated_id: :sections_shall_populated,
        populated_title: 'AU PS Composition Mandatory Sections are correctly populated',
        populated_description: 'Mandatory section SHALL be correctly populated if a value is known',
        entry_profiles_id: :mandatory_sections_entry_profiles,
        entry_profiles_title: 'AU PS Composition Mandatory Sections capable of populating referenced profiles',
        entry_profiles_description: 'Mandatory section SHALL be capable of populating section.entry with the ' \
                                    'referenced profiles and SHOULD correctly populate section.entry if a value is known.',
        entry_profiles_method: :test_composition_mandatory_sections,
        entry_profiles_dsl_optional: false
      },
      {
        group_id: :au_ps_composition_recommended_sections,
        group_title: 'AU PS Composition Recommended Sections',
        group_description: 'Verify the recommended sections are correctly populated in the Composition resource',
        codes: %w[11369-6 30954-2 47519-4 46264-8],
        populated_optional: true,
        populated_id: :sections_should_populated,
        populated_title: 'AU PS Composition recommended sections are correctly populated',
        populated_description: 'Recommended sections SHOULD be correctly populated if a value is known',
        entry_profiles_id: :recommended_sections_entry_profiles,
        entry_profiles_title: 'AU PS Composition Recommended Sections capable of populating referenced profiles',
        entry_profiles_description: 'Recommended section SHALL be capable of populating section.entry with the ' \
                                    'referenced profiles and SHOULD correctly populate section.entry if a value is known.',
        entry_profiles_method: :test_composition_recommended_sections,
        entry_profiles_dsl_optional: false
      },
      {
        group_id: :au_ps_composition_optional_sections,
        group_title: 'AU PS Composition Optional Sections',
        group_description: 'Verify the optional sections are correctly populated in the AU PS Composition resource',
        codes: %w[42348-3 104605-1 47420-5 11348-0 10162-6 81338-6 18776-5 29762-2 8716-3],
        populated_optional: true,
        populated_id: :sections_may_populated,
        populated_title: 'AU PS Composition optional sections are correctly populated',
        populated_description: 'Optional section MAY be correctly populated if a value is known',
        entry_profiles_id: :optional_sections_entry_profiles,
        entry_profiles_title: 'AU PS Composition Optional Sections capable of populating referenced profiles',
        entry_profiles_description: 'Optional section SHALL be capable of populating section.entry with the ' \
                                    'referenced profiles and SHOULD correctly populate section.entry if a value is known.',
        entry_profiles_method: :test_composition_optional_sections,
        entry_profiles_dsl_optional: true
      }
    ].freeze

    ACTOR_GROUPS = [
      {
        key: 'subject',
        group_id: :au_ps_composition_subject,
        group_title: 'AU PS Composition Subject',
        group_description: 'Verify the referenced subject is a correctly populated AU PS Patient resource.',
        group_optional: false,
        resource_type_id: :subject_resource_type_is_valid,
        resource_type_text: 'Subject reference in the AU PS Composition SHALL resolve to a valid resource ' \
                            'type (Patient).',
        ms_elements_id: :subject_ms_elements,
        ms_elements_text: 'Must Support elements SHALL be populated if a value is known',
        ms_subelements_id: :subject_ms_subelements_populated,
        ms_subelements_text: 'Must Support sub-element SHALL be populated if a value is known and the parent is populated',
        ms_identifier_slices_id: :subject_ms_identifier_slices,
        ms_identifier_slices_title: 'Must Support identifier slices SHALL be populated if a value is known',
        ms_identifier_slices_description: 'Must Support identifier slices SHALL be populated if a value is ' \
                                          'known (i.e. ihi, dva, medicare).',
        ms_identifier_slices_method: :test_subject_ms_identifier_slices
      },
      {
        key: 'author',
        group_id: :au_ps_composition_author,
        group_title: 'AU PS Composition Author',
        group_description: 'Verify the referenced author is a correctly populated AU PS Practitioner, AU PS ' \
                           'PractitionerRole, AU PS Patient, AU PS RelatedPerson, AU PS Organization profiles ' \
                           'or Device resource.',
        group_optional: false,
        resource_type_id: :author_resource_type_is_valid,
        resource_type_text: 'Author reference in the AU PS Composition SHALL resolve to a valid resource type ' \
                            '(Practitioner, PractitionerRole, Device, Patient, RelatedPerson, Organization).',
        ms_elements_id: :author_ms_elements,
        ms_elements_text: 'Must Support elements SHALL be populated if a value is known',
        ms_subelements_id: :author_ms_subelements,
        ms_subelements_text: 'Must Support sub-elements SHALL be populated if a value is known',
        ms_identifier_slices_id: :author_ms_identifier_slices,
        ms_identifier_slices_title: 'Must Support identifier slices SHALL be populated if a value is known',
        ms_identifier_slices_description: 'Must Support identifier slices SHALL be populated if a value is known',
        ms_identifier_slices_method: :test_composition_author_ms_identifier_slices
      },
      {
        key: 'custodian',
        group_id: :au_ps_composition_custodian,
        group_title: 'AU PS Composition Custodian',
        group_description: 'Verify the referenced custodian is a correctly populated AU PS Organization resource.',
        group_optional: true,
        resource_type_id: nil,
        resource_type_text: nil,
        ms_elements_id: :custodian_ms_elements,
        ms_elements_text: 'Must Support element SHALL be populated if a value is known',
        ms_subelements_id: :custodian_ms_subelements,
        ms_subelements_text: 'Must Support sub-element SHALL be populated if a value is known',
        ms_identifier_slices_id: :custodian_ms_identifier_slices,
        ms_identifier_slices_title: 'Must Support identifier slices SHALL be populated if a value is known',
        ms_identifier_slices_description: 'Must Support identifier slices SHALL be populated if a value is known',
        ms_identifier_slices_method: :test_composition_custodian_ms_identifier_slices
      },
      {
        key: 'attester',
        group_id: :au_ps_composition_attester,
        group_title: 'AU PS Composition Attester',
        group_description: 'Verify the referenced attester.party is a correctly populated AU PS Patient, ' \
                           'RelatedPerson, Practitioner, PractitionerRole, or Organization resource.',
        group_optional: true,
        resource_type_id: nil,
        resource_type_text: nil,
        ms_elements_id: :attester_party_ms_elements,
        ms_elements_text: 'Must Support elements SHALL be populated if a value is known',
        ms_subelements_id: :attester_party_ms_subelements,
        ms_subelements_text: 'Must Support sub-element SHALL be populated if a value is known',
        ms_identifier_slices_id: :attester_party_ms_identifier_slices,
        ms_identifier_slices_title: 'Must Support identifier slices SHALL be populated if a value is known',
        ms_identifier_slices_description: 'Must Support identifier slices SHALL be populated if a value is known',
        ms_identifier_slices_method: :test_composition_attester_party_ms_identifier_slices
      }
    ].freeze

    BUNDLE_SOURCES.each do |source|
      group do
        id source[:top_id]
        title source[:top_title]
        description source[:top_description]
        run_as_group

        group do
          id :bundle_acquisition
          title source[:acquisition_group_title]
          description source[:acquisition_group_description]
          run_as_group

          test from: source[:acquisition_from] do
            id :bundle_provide
            title source[:acquisition_test_title]
            description source[:acquisition_test_description]
          end
        end

        group do
          id :bundle_validation
          title 'Bundle Validation'
          description 'Validates that the bundle conforms to the Bundle profiles.'
          run_as_group

          test from: :bundle_is_valid_class_test do
            id :bundle_valid
            title source[:bundle_valid_title]
            description source[:bundle_valid_description]
          end

          test from: :ips_bundle_is_valid_class_base do
            id :bundle_valid_ips
            title source[:bundle_valid_ips_title]
            description source[:bundle_valid_ips_description]
          end
        end

        group do
          id :au_ps_bundle_must_support_conformance
          title 'AU PS Bundle Must Support Conformance'
          description 'Verifies that Must Support elements at the bundle level are populated when data is available.'
          run_as_group

          test from: :single_file_basic_test do
            id :bundle_must_support_populated
            title 'AU PS Bundle Must Support elements are correctly populated'
            description 'Must Support elements SHALL be populated when an element value is known and allowed to share.'
            run { bundle_mandatory_ms_elements_info }
          end
        end

        group do
          id :au_ps_composition_must_support_conformance
          title 'AU PS Composition Must Support Conformance'
          description 'Verifies that Composition Must Support elements (mandatory, optional, sub-elements, ' \
                      'slices) are correctly populated when data is known.'
          run_as_group

          test from: :single_file_basic_test do
            id :composition_mandatory_ms_populated
            title 'Mandatory Must Support elements are correctly populated'
            description 'Mandatory Must Support element SHALL be able to be populated if a value is known ' \
                        'and allowed to share.'
            run { validate_populated_elements_in_composition(%w[author date status subject title type]) }
          end

          test from: :single_file_basic_test do
            id :composition_optional_ms_populated
            title 'Optional Must Support elements are correctly populated'
            description 'Optional Must Support elements SHALL be correctly populated if a value is known'
            run do
              validate_populated_elements_in_composition(%w[attester custodian identifier text event], required: false)
            end
          end

          test from: :single_file_basic_test do
            id :composition_ms_subelements_populated
            title 'Must Support sub-elements of a complex element are correctly populated'
            description 'Must Support sub-elements of a complex element SHALL be correctly populated if a value is known'
            run do
              validate_populated_sub_elements_in_composition(['attester.mode', 'subject.reference'],
                                                             ['attester.party', 'attester.time'])
            end
          end

          test from: :single_file_basic_test do
            id :composition_optional_ms_slices
            title 'Must Support slices are correctly populated'
            description 'Must Support slice careProvisioningEvent SHALL be populated if a value is known.'
            run do
              validate_populated_slices_in_composition(
                [{ path: 'event', sliceName: 'careProvisioningEvent', min: 0, max: '1', mustSupport: true,
                   mandatory_ms_sub_elements: ['period'], optional_ms_sub_elements: ['code'] }]
              )
            end
          end
        end

        SECTION_TIERS.each do |tier|
          group do
            id tier[:group_id]
            title tier[:group_title]
            description tier[:group_description]
            run_as_group

            test from: :single_file_basic_test do
              id tier[:populated_id]
              title tier[:populated_title]
              description tier[:populated_description]
              run do
                validate_populated_sections_in_bundle(tier[:codes], %w[title code text],
                                                      optional: tier[:populated_optional])
              end
            end

            test from: :single_file_basic_test do
              id tier[:entry_profiles_id]
              title tier[:entry_profiles_title]
              description tier[:entry_profiles_description]
              optional if tier[:entry_profiles_dsl_optional]
              # send, not public_send: test_composition_*_sections are declared private
              # in BasicTestCompositionSectionReadModule (callable via the bare, implicit-
              # receiver calls the generated files used; send reproduces that here).
              run { send(tier[:entry_profiles_method]) }
            end
          end
        end

        group do
          id :au_ps_composition_undefined_sections
          title 'AU PS Composition Undefined Sections'
          description 'Verify the undefined sections are correctly populated in the AU PS Composition resource.'
          optional
          run_as_group

          test from: :single_file_basic_test do
            id :sections_may_undefined
            title 'Undefined sections are correctly populated'
            description 'Undefined sections MAY be populated if a value is known'
            run do
              validate_populated_undefined_sections_in_bundle(
                %w[11450-4 48765-2 10160-0 11369-6 30954-2 47519-4 46264-8 42348-3 104605-1 47420-5
                   11348-0 10162-6 81338-6 18776-5 29762-2 8716-3], %w[title code text]
              )
            end
          end
        end

        ACTOR_GROUPS.each do |actor|
          group do
            id actor[:group_id]
            title actor[:group_title]
            description actor[:group_description]
            optional if actor[:group_optional]
            run_as_group

            if actor[:resource_type_id]
              test from: :single_file_basic_test do
                id actor[:resource_type_id]
                title actor[:resource_type_text]
                description actor[:resource_type_text]
                run { test_resource_type_is_valid?(actor[:key]) }
              end
            end

            test from: :single_file_basic_test do
              id actor[:ms_elements_id]
              title actor[:ms_elements_text]
              description actor[:ms_elements_text]
              run { ms_elements_populated_message(actor[:key]) }
            end

            test from: :single_file_basic_test do
              id actor[:ms_subelements_id]
              title actor[:ms_subelements_text]
              description actor[:ms_subelements_text]
              run { ms_sub_elements_populated_message(actor[:key]) }
            end

            test from: :single_file_basic_test do
              id actor[:ms_identifier_slices_id]
              title actor[:ms_identifier_slices_title]
              description actor[:ms_identifier_slices_description]
              run { public_send(actor[:ms_identifier_slices_method]) }
            end
          end
        end
      end
    end

    group from: :au_ps_retrieve_cs_group_100preview
  end
end
