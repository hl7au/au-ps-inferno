# frozen_string_literal: true


require_relative 'bundle_validation/bundle_validation'

require_relative 'retrieve_bundle_validation/retrieve_bundle_validation'

require_relative 'generate_bundle_using_ips_summary_validation/generate_bundle_using_ips_summary_validation'


module AUPSTestKit
  # Automatically generated suite for 1.0.0-ballot
  class AUPSSuite100ballot < Inferno::TestSuite
    id :suite_100ballot
    title '1.0.0-ballot'
    description 'Suite for 1.0.0-ballot'

    fhir_resource_validator do
      igs 'hl7.fhir.au.ps#100ballot'

      cli_context do
        txServer ENV.fetch('TX_SERVER_URL', 'https://tx.dev.hl7.org.au/fhir')
      end
    end

    
    group from: :suite_100ballot_bundle_validation
    
    group from: :suite_100ballot_retrieve_bundle_validation
    
    group from: :suite_100ballot_generate_bundle_using_ips_summary_validation
    
  end
end

