# frozen_string_literal: true

require 'ips_test_kit'
require_relative 'au_ips_inferno/summary_operation_group'

module AUIPSInferno
  # AU PS suite
  class Suite < Inferno::TestSuite
    id :au_ips_inferno
    title 'AU IPS Inferno Test Suite'
    description 'Inferno template test suite.'

    # These inputs will be available to all tests in this suite
    input :url,
          title: 'FHIR Server Base Url'

    input :credentials,
          title: 'OAuth Credentials',
          type: :oauth_credentials,
          optional: true

    # All FHIR requests in this suite will use this FHIR client
    fhir_client do
      url :url
      oauth_credentials :credentials
    end

    fhir_resource_validator do
      igs 'hl7.fhir.uv.ips#1.1.0'
    end

    group from: :ips_resource_validation
    group do
      title 'IPS Server Operations for Generating IPS Bundles Tests'
      short_title 'IPS Operation Tests'
      description %(
        This group evaluates the ability of systems to provide a standard FHIR
        API for generating and communicating an IPS Bundle as described in the
        [IPS Data Generation and Inclusion Guidance](http://hl7.org/fhir/uv/ips/STU1.1/ipsGeneration.html).

        Please note that the DocRef tests are currently of limited scope.
      )

      input :url, title: 'IPS FHIR Server Base URL'

      fhir_client do
        url :url
      end

      group from: :ips_summary_group
    end
  end
end
