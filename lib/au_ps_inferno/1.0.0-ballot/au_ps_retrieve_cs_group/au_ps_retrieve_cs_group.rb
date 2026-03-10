# frozen_string_literal: true


require_relative './au_ps_cs_is_valid_test'

require_relative './au_ps_cs_supports_ips_recommended_ops'

require_relative './au_ps_cs_supports_au_ps_profiles'


module AUPSTestKit
  # Tests for CapabilityStatement resource
  class AUPSRetrieveCSGroup100ballot < Inferno::TestGroup
    title 'Retrieve Capability Statement'
    description 'Verifies that the server exposes a valid CapabilityStatement and declares support for AU PS profiles and IPS recommended operations.'
    id :au_ps_retrieve_cs_group_100ballot

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
      headers(header_name.present? && header_value.present? ? { header_name => header_value } : {})
    end

    run_as_group

    
    test from: :au_ps_cs_is_valid_100ballot
    
    test from: :au_ps_cs_supports_ips_recommended_ops_100ballot
    
    test from: :au_ps_cs_supports_au_ps_profiles_100ballot
    
  end
end
