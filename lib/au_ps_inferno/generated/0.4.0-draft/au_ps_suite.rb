# frozen_string_literal: true

require_relative './au_ps_validation_group/au_ps_validation_group'
require_relative './au_ps_retrieve_cs_group/au_ps_retrieve_cs_group'
require_relative './au_ps_retrieve_bundle_group/au_ps_retrieve_bundle_group'
require_relative './au_ps_summary_bundle_group/au_ps_summary_bundle_group'

module AUPSTestKit
  class Suite < Inferno::TestSuite
    id :au_ps_suite
    title 'AU PS Inferno - $summary'
    description 'This suite includes $summary operation tests.'

    input :url,
          title: 'FHIR Server Base Url',
          optional: true

    input :credentials,
          title: 'OAuth Credentials',
          type: :oauth_credentials,
          optional: true

     input :header_name,
           title: 'Header name',
           optional: true
     input :header_value,
           title: 'Header value',
           optional: true

    fhir_client do
      url :url
      oauth_credentials :credentials
      headers (header_name && header_value) ? {header_name => header_value} : {}
    end

    fhir_resource_validator do
      igs 'hl7.fhir.au.ps#0.4.0-draft'

      
      cli_context do
        txServer ENV.fetch('TX_SERVER_URL', 'https://tx.dev.hl7.org.au/fhir')
      end
      
    end

    group from: :au_ps_validation_group
    group from: :au_ps_retrieve_cs_group
    group from: :au_ps_retrieve_bundle_group
    group from: :au_ps_summary_bundle_group

  end
end
