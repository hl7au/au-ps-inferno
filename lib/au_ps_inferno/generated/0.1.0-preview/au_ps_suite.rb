# frozen_string_literal: true


require_relative './summary_operation_group/au_ps_summary_operation_group'

require_relative './entries_group/au_ps_entries_group'

require_relative './docref_operation_group/au_ps_docref_group'


module AUPSTestKit
  class Suite < Inferno::TestSuite
    id :au_ps_suite
    title 'AU PS Inferno'
    description 'AU PS Inferno consist of $summary tests, $summary entries tests and $docref tests'

    input :url,
          title: 'FHIR Server Base Url'

    input :credentials,
          title: 'OAuth Credentials',
          type: :oauth_credentials,
          optional: true

    fhir_client do
      url :url
      oauth_credentials :credentials
    end

    fhir_resource_validator do
      igs 'hl7.fhir.au.ps#0.1.0-preview'

      
      cli_context do
        txServer ENV.fetch('TX_SERVER_URL', 'https://tx.dev.hl7.org.au/fhir')
      end
      
    end

    
    group from: :au_ps_summary_operation
    
    group from: :au_ps_entries
    
    group from: :au_ps_docref_operation_group
    
  end
end
