# frozen_string_literal: true

require_relative 'basic_test_class'

module AUPSTestKit
  # Retrieves a Bundle from a FHIR server (or a direct URL) into the group's scratch space
  class RetrieveBundleTestClass < BasicTest
    id :retrieve_bundle_test_class
    input_order :bundle_url, :url, :bundle_id, :credentials, :header_name, :header_value

    NO_RETRIEVAL_INPUTS_MESSAGE = 'No FHIR server URL with Bundle ID, and no Bundle URL, were provided, ' \
                                  'so this test group is omitted.'

    input :bundle_id,
          optional: true,
          description: 'To request Bundle/{bundle_id}'

    input :bundle_url,
          optional: true,
          description: 'To retrieve document Bundle using HTTP GET request'

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

    def get_bundle_resource_from_fhir_server(bundle_id)
      fhir_read(:bundle, bundle_id)
      assert_response_status(200)
      assert_resource_type(:bundle)
      save_bundle_to_scratch(resource)
    end

    def get_bundle_resource_from_url(bundle_url)
      get(bundle_url, headers: extra_headers)
      assert_response_status(200)
      bundle_resource = parse_bundle(request.response_body)
      assert bundle_resource.present?, "The response from #{bundle_url} could not be parsed as a FHIR resource"
      assert bundle_resource.resourceType == 'Bundle',
             "The resource at #{bundle_url} is a #{bundle_resource.resourceType}, expected a Bundle"
      save_bundle_to_scratch(bundle_resource)
    end

    def extra_headers
      header_name.present? && header_value.present? ? { header_name => header_value } : {}
    end

    def parse_bundle(body)
      FHIR.from_contents(body)
    rescue StandardError
      nil
    end

    def skip_test?
      !((url.present? && bundle_id.present?) || bundle_url.present?)
    end

    def read_and_save_data
      if url.present? && bundle_id.present?
        get_bundle_resource_from_fhir_server(bundle_id)
      elsif bundle_url.present?
        get_bundle_resource_from_url(bundle_url)
      end
    end

    run do
      omit_if skip_test?, NO_RETRIEVAL_INPUTS_MESSAGE
      read_and_save_data
    end
  end
end
