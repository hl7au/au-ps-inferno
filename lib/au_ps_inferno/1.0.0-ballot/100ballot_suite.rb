# frozen_string_literal: true


require_relative 'au_ps_bundle_instance/au_ps_bundle_instance'

require_relative 'au_ps_retrieve_cs_group/au_ps_retrieve_cs_group'

require_relative 'retrieve_au_ps_bundle_validation_tests/retrieve_au_ps_bundle_validation_tests'

require_relative 'generate_au_ps_using_ips_summary_validation_tests/generate_au_ps_using_ips_summary_validation_tests'


module AUPSTestKit
  # Automatically generated suite for AU PS 1.0.0-ballot Test Suite
  class AUPSSuite100ballot < Inferno::TestSuite
    id :suite_100ballot
    title 'AU PS 1.0.0-ballot Test Suite'
    description 'Validates AU PS (Australian Primary Care and Shared Health) bundles, compositions, sections, and server CapabilityStatement support for the 1.0.0-ballot implementation guide.'

    fhir_resource_validator do
      igs 'hl7.fhir.au.ps#1.0.0-ballot'

      cli_context do
        txServer ENV.fetch('TX_SERVER_URL', 'https://tx.dev.hl7.org.au/fhir')
      end
    end

    
    group from: :suite_100ballot_au_ps_bundle_instance
    
    group from: :au_ps_retrieve_cs_group_100ballot
    
    group from: :suite_100ballot_retrieve_au_ps_bundle_validation_tests
    
    group from: :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests
    
  end
end

