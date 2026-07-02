# frozen_string_literal: true

require_relative '../1.0.0-preview/100preview_suite'

module AUPSTestKit
  # Automatically generated alias: always mirrors the latest generated IG version
  # (currently 1.0.0-preview), registered under the stable, version-agnostic :suite id.
  class AUPSSuite < Inferno::TestSuite
    id :suite
    title 'AU PS 1.0.0-preview Test Suite'
    description 'Validates AU PS (Australian Primary Care and Shared Health) bundles, ' \
                'compositions, sections, and server CapabilityStatement support for the ' \
                '1.0.0-preview implementation guide.'

    fhir_resource_validator do
      igs 'hl7.fhir.au.ps#1.0.0-preview'

      cli_context do
        txServer ENV.fetch('TX_SERVER_URL', 'https://tx.dev.hl7.org.au/fhir')
        noEcosystem true
      end
    end

    group from: :suite_au_ps_bundle_instance_100preview

    group from: :au_ps_retrieve_cs_group_100preview

    group from: :suite_retrieve_au_ps_bundle_validation_tests_100preview

    group from: :suite_generate_au_ps_using_ips_summary_validation_tests_100preview

  end
end
