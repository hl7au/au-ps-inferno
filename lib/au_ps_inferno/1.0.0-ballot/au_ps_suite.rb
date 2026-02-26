# frozen_string_literal: true


require_relative './au_ps_validation_group/au_ps_validation_group'

require_relative './au_ps_retrieve_cs_group/au_ps_retrieve_cs_group'

require_relative './au_ps_retrieve_bundle_group/au_ps_retrieve_bundle_group'

require_relative './au_ps_summary_bundle_group/au_ps_summary_bundle_group'

require_relative './au_ps_sections_validation_group/au_ps_sections_validation_group'


module AUPSTestKit
  # The test suite for the AU PS Inferno profile.
  class Suite100ballot < Inferno::TestSuite
    id :au_ps_suite_100ballot
    title 'AU PS Inferno 1.0.0-ballot'
    description 'This suite includes $summary operation tests.'

    fhir_resource_validator do
      igs 'hl7.fhir.au.ps#1.0.0-ballot'

      cli_context do
        txServer ENV.fetch('TX_SERVER_URL', 'https://tx.dev.hl7.org.au/fhir')
      end
    end

    
    group from: :au_ps_validation_group_100ballot
    
    group from: :au_ps_retrieve_cs_group_100ballot
    
    group from: :au_ps_retrieve_bundle_group_100ballot
    
    group from: :au_ps_summary_bundle_group_100ballot
    
    group from: :au_ps_sections_validation_group_100ballot
    
  end
end
