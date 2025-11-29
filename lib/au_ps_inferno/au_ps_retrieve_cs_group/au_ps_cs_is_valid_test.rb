# frozen_string_literal: true

require_relative '../utils/constants'

module AUPSTestKit
  class AUPSCSIsValid < Inferno::Test
    include Constants

    title TEXTS[:au_ps_cs_is_valid][:title]
    description TEXTS[:au_ps_cs_is_valid][:description]
    id :au_ps_cs_is_valid

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

    run do
      skip_if url.blank?, 'No FHIR server specified'
      fhir_get_capability_statement
      scratch[:capability_statement] = resource
      info "Capability Statement saved to scratch: #{scratch[:capability_statement]}"
      assert_response_status(200)
      assert_resource_type(:capability_statement)
    end
  end
end
