# frozen_string_literal: true

require_relative './au_ps_validation_group/au_ps_validation_group'
require_relative './au_ps_retrieve_cs_group/au_ps_retrieve_cs_group'
require_relative './au_ps_retrieve_bundle_group/au_ps_retrieve_bundle_group'
require_relative './au_ps_summary_bundle_group/au_ps_summary_bundle_group'
require_relative './au_ps_sections_validation_group/au_ps_sections_validation_group'

module AUPSTestKit
  # The test suite for the AU PS Inferno profile.
  class Suite < Inferno::TestSuite
    id :au_ps_suite
    title 'AU PS Inferno'
    description 'This suite includes $summary operation tests.'

    fhir_resource_validator do
      igs 'hl7.fhir.au.ps#0.5.0-preview'

      cli_context do
        txServer ENV.fetch('TX_SERVER_URL', 'https://tx.dev.hl7.org.au/fhir')
      end
    end

    group from: :au_ps_validation_group
    group from: :au_ps_retrieve_cs_group
    group from: :au_ps_retrieve_bundle_group
    group from: :au_ps_summary_bundle_group
    group from: :au_ps_sections_validation_group
  end
end
