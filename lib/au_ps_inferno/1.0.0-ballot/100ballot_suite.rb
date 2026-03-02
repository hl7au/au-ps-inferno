# frozen_string_literal: true


require_relative 'bundle_validation_high_order_group/bundle_validation_high_order_group'

require_relative 'retrieve_bundle_validation_high_order_group/retrieve_bundle_validation_high_order_group'

require_relative 'generate_bundle_using_ips_summary_validation_high_order_group/generate_bundle_using_ips_summary_validation_high_order_group'


module AUPSTestKit
  # Automatically generated suite for 1.0.0-ballot
  class Suite100ballot < Inferno::TestSuite
    id :suite_100ballot
    title '1.0.0-ballot'
    description 'Suite for 1.0.0-ballot'

    fhir_resource_validator do
      igs 'hl7.fhir.au.ps#100ballot'

      cli_context do
        txServer ENV.fetch('TX_SERVER_URL', 'https://tx.dev.hl7.org.au/fhir')
      end
    end

    
    group from: :bundle_validation
    
    group from: :retrieve_bundle_validation
    
    group from: :generate_bundle_using_ips_summary_validation
    
  end
end

