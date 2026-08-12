# frozen_string_literal: true

require_relative '../utils/basic_test_class'
require_relative '../utils/metadata_manager'
require_relative '../utils/provided_bundle_test_class'
require_relative '../utils/retrieve_bundle_test_class'
require_relative '../utils/generate_summary_bundle_test_class'
require_relative '../utils/bundle_is_valid_class'
require_relative '../utils/ips_bundle_is_valid_class'
require_relative 'au_ps_retrieve_cs_group/au_ps_retrieve_cs_group'
require_relative 'single_file_suite_config'

module AUPSTestKit
  # Builds an Approach-A single-file suite
  module SingleFileSuiteBuilder
    def self.build(suite_id:, ig_version:, suite_title:, suite_description:, metadata_dir:,
                   section_tiers: SingleFileSuiteConfig::DEFAULT_SECTION_TIERS)
      basic_test_class = build_basic_test_class(suite_id, metadata_dir)
      all_section_codes = section_tiers.flat_map { |tier| tier[:codes] }

      suite_class = Class.new(Inferno::TestSuite) do
        id suite_id
        title suite_title
        description suite_description

        fhir_resource_validator do
          igs "hl7.fhir.au.ps##{ig_version}"

          cli_context do
            txServer ENV.fetch('TX_SERVER_URL', 'https://tx.dev.hl7.org.au/fhir')
            snomedCT ENV.fetch('SNOMED_EDITION', 'au')
            noEcosystem true
          end
        end

        SingleFileSuiteConfig::BUNDLE_SOURCES.each do |source|
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

                define_method(:validate_au_ps_bundle) do
                  validate_bundle_wrapper("http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle|#{ig_version}")
                end
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

              test from: basic_test_class.id do
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

              test from: basic_test_class.id do
                id :composition_mandatory_ms_populated
                title 'Mandatory Must Support elements are correctly populated'
                description 'Mandatory Must Support element SHALL be able to be populated if a value is known ' \
                            'and allowed to share.'
                run { validate_populated_elements_in_composition(%w[author date status subject title type]) }
              end

              test from: basic_test_class.id do
                id :composition_optional_ms_populated
                title 'Optional Must Support elements are correctly populated'
                description 'Optional Must Support elements SHALL be correctly populated if a value is known'
                run do
                  validate_populated_elements_in_composition(%w[attester custodian identifier text event],
                                                             required: false)
                end
              end

              test from: basic_test_class.id do
                id :composition_ms_subelements_populated
                title 'Must Support sub-elements of a complex element are correctly populated'
                description 'Must Support sub-elements of a complex element SHALL be correctly populated if a value is known'
                run do
                  validate_populated_sub_elements_in_composition(['attester.mode', 'subject.reference'],
                                                                 ['attester.party', 'attester.time'])
                end
              end

              test from: basic_test_class.id do
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

            section_tiers.each do |tier|
              group do
                id tier[:group_id]
                title tier[:group_title]
                description tier[:group_description]
                run_as_group

                test from: basic_test_class.id do
                  id tier[:populated_id]
                  title tier[:populated_title]
                  description tier[:populated_description]
                  run do
                    validate_populated_sections_in_bundle(tier[:codes], %w[title code text],
                                                          optional: tier[:populated_optional])
                  end
                end

                test from: basic_test_class.id do
                  id tier[:entry_profiles_id]
                  title tier[:entry_profiles_title]
                  description tier[:entry_profiles_description]
                  optional if tier[:entry_profiles_dsl_optional]

                  run do
                    omit_unless_bundle_in_scratch
                    test_composition_sections_data(sections_codes: tier[:codes], bundle_data: scratch_bundle,
                                                   mandatory: tier[:mandatory])
                  end
                end

                if tier[:nilknown_warning_id]
                  test from: basic_test_class.id do
                    id tier[:nilknown_warning_id]
                    title tier[:nilknown_warning_title]
                    description tier[:nilknown_warning_description]
                    run { warn_on_nilknown_empty_reason(tier[:codes]) }
                  end
                end
              end
            end

            group do
              id :au_ps_composition_undefined_sections
              title 'AU PS Composition Undefined Sections'
              description 'Verify the undefined sections are correctly populated in the AU PS Composition resource.'
              optional
              run_as_group

              test from: basic_test_class.id do
                id :sections_may_undefined
                title 'Undefined sections are correctly populated'
                description 'Undefined sections MAY be populated if a value is known'
                run { validate_populated_undefined_sections_in_bundle(all_section_codes, %w[title code text]) }
              end
            end

            SingleFileSuiteConfig::ACTOR_GROUPS.each do |actor|
              group do
                id actor[:group_id]
                title actor[:group_title]
                description actor[:group_description]
                optional if actor[:group_optional]
                run_as_group

                if actor[:resource_type_id]
                  test from: basic_test_class.id do
                    id actor[:resource_type_id]
                    title actor[:resource_type_text]
                    description actor[:resource_type_text]
                    run { test_resource_type_is_valid?(actor[:key]) }
                  end
                end

                test from: basic_test_class.id do
                  id actor[:ms_elements_id]
                  title actor[:ms_elements_text]
                  description actor[:ms_elements_text]
                  run { ms_elements_populated_message(actor[:key]) }
                end

                test from: basic_test_class.id do
                  id actor[:ms_subelements_id]
                  title actor[:ms_subelements_text]
                  description actor[:ms_subelements_text]
                  run { ms_sub_elements_populated_message(actor[:key]) }
                end

                test from: basic_test_class.id do
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

      suite_class.add_self_to_repository
      suite_class
    end

    # @private
    def self.build_basic_test_class(suite_id, metadata_dir)
      klass = Class.new(BasicTest) do
        id :"#{suite_id}_basic_test"

        define_method(:metadata_manager) do
          @metadata_manager ||= MetadataManager.new(File.expand_path('metadata.yaml', metadata_dir))
        end
      end
      klass.add_self_to_repository
      klass
    end
    private_class_method :build_basic_test_class
  end
end
