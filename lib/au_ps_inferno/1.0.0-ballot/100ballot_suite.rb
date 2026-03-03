# frozen_string_literal: true


require_relative 'au_ps_bundle_instance/au_ps_bundle_instance'

require_relative 'retrieved_bundle/retrieved_bundle'

require_relative 'generated_bundle_ips_summary/generated_bundle_ips_summary'

require_relative 'au_ps_sections_validation_group/au_ps_sections_validation_group'

require_relative 'au_ps_retrieve_cs_group/au_ps_retrieve_cs_group'


module AUPSTestKit
  # Automatically generated suite for AU PS 1.0.0-ballot Test Suite
  class AUPSSuite100ballot < Inferno::TestSuite
    id :suite_100ballot
    title 'AU PS 1.0.0-ballot Test Suite'
    description 'Validates AU PS (Australian Primary Care and Shared Health) bundles, compositions, sections, and server CapabilityStatement support for the 1.0.0-ballot implementation guide.'

    fhir_resource_validator do
      igs 'hl7.fhir.au.ps#100ballot'

      cli_context do
        txServer ENV.fetch('TX_SERVER_URL', 'https://tx.dev.hl7.org.au/fhir')
      end
    end

    
    group from: :suite_100ballot_au_ps_bundle_instance
    
    group from: :suite_100ballot_retrieved_bundle
    
    group from: :suite_100ballot_generated_bundle_ips_summary
    
    group from: :au_ps_sections_validation_group_100ballot
    
    group from: :au_ps_retrieve_cs_group_100ballot
    
  end
end

