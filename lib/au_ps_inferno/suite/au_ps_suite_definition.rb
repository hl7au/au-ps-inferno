# frozen_string_literal: true

require 'inferno_suite_generator/utils/fhirpath_lab_message_linker'

require 'inferno_suite_generator/utils/resource_keeper_endpoints'

require_relative '../suite_version'
require_relative '../utils/address_country_check'

require_relative 'au_ps_bundle_instance/au_ps_bundle_instance'

require_relative 'au_ps_retrieve_cs_group/au_ps_retrieve_cs_group'

require_relative 'retrieve_au_ps_bundle_validation_tests/retrieve_au_ps_bundle_validation_tests'

require_relative 'generate_au_ps_using_ips_summary_validation_tests/generate_au_ps_using_ips_summary_validation_tests'

module AUPSTestKit
  # The body shared by every AU PS suite version. A version's suite class extends this
  # module and calls {#define_au_ps_suite} with its {SuiteVersion}; the version supplies the
  # suite id, the validator package and, through Inferno's +config+ options, the metadata
  # file and profile version every shared group and test reads at run time.
  #
  # Group and test ids come from the shared group classes, and Inferno prefixes each one
  # with the id of the suite that includes it (+au_ps_v100-suite_au_ps_bundle_instance-...+),
  # so every suite version gets its own ids and several versions coexist in one process.
  module AUPSSuiteDefinition
    DEFAULT_TX_SERVER_URL = 'https://tx.dev.hl7.org.au/fhir'

    # @param version [AUPSTestKit::SuiteVersion]
    # @param title [String]
    # @param description [String]
    def define_au_ps_suite(version, title:, description:)
      id version.suite_id
      self.title(title)
      self.description(description)

      au_ps_validator(version)
      au_ps_endpoints
      au_ps_groups

      config options: version.runnable_options
    end

    private

    def au_ps_validator(version)
      metadata_path = version.metadata_path

      fhir_resource_validator do
        igs version.validator_package

        perform_additional_validation do |resource, _profile_url|
          AUPSTestKit::AddressCountryCheck.messages_for(resource, metadata_path:)
        end

        cli_context do
          txServer ENV.fetch('TX_SERVER_URL', DEFAULT_TX_SERVER_URL)
          # The validator defaults snomedCT to the International edition
          # (900000000000207008) and turns it into an expansion parameter
          # "system-version=http://snomed.info/sct|http://snomed.info/sct/<edition>".
          # The AU terminology server carries only the Australian edition, so the
          # default makes every SNOMED lookup fail with "A definition for CodeSystem
          # 'http://snomed.info/sct' version 'null' could not be found", and the
          # validator then reports valid codes as absent from their value sets.
          # The AU edition is a derivative containing the full International release
          # plus the AU extension and AMT, so nothing is lost by selecting it, and
          # AMT codes (required binding on AU Core Medication.code.coding:amt) are
          # only resolvable here.
          snomedCT ENV.fetch('SNOMED_EDITION', 'au')
          noEcosystem true
        end
      end
    end

    def au_ps_endpoints
      const_set(:FHIRPATHLAB_URL, ENV.fetch('FHIRPATHLAB_URL', 'https://fhirpath-lab.com/FhirPath').presence)

      suite_endpoint :get, '/resources/:session_id/:resource_type/:resource_id',
                     InfernoSuiteGenerator::FetchResourceEndpoint
      suite_endpoint :delete, '/resources/:session_id',
                     InfernoSuiteGenerator::DeleteSessionResourcesEndpoint
    end

    def au_ps_groups
      group from: :suite_au_ps_bundle_instance

      group from: :au_ps_retrieve_cs_group_100preview
      group from: :suite_retrieve_au_ps_bundle_validation_tests
      group from: :suite_generate_au_ps_using_ips_summary_validation_tests
    end
  end
end
