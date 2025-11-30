# frozen_string_literal: true

module AUPSTestKit
  # A base class for all tests with FHIR server URL to decrease code duplication
  class BasicTestWithURL < BasicTest
    id :basic_test_with_url
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
  end
end
