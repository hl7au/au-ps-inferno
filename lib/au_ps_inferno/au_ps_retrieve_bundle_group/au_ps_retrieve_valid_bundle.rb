# frozen_string_literal: true

require 'net/http'
require 'uri'

require_relative '../utils/basic_test_class'

module AUPSTestKit
  # The Bundle resource is valid against the AU PS Bundle profile
  class AUPSRetrieveValidBundle < BasicTest
    id :au_ps_retrieve_valid_bundle
    title 'Server provides valid requested AU PS Bundle'
    description 'Retrieve document Bundle using Bundle read interaction or other HTTP GET request and ' \
      'verify response is valid AU PS Bundle'

    input :bundle_id,
          optional: true,
          description: 'To request Bundle/{bundle_id}'

    input :bundle_url,
          optional: true,
          description: 'To request Patient/$summary?identifier={identifier}'

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
      info "Retrieving Bundle resource with id #{bundle_id}"
      fhir_read(:bundle, bundle_id)
      assert_response_status(200)
      assert_resource_type(:bundle)
      scratch[:bundle_ips_resource] = resource
      info "Bundle resource saved to scratch: #{scratch_bundle}"
    end

    def get_bundle_resource_from_url(bundle_url)
      info "Retrieving Bundle resource from url #{bundle_url}"
      uri = URI(bundle_url)
      response = Net::HTTP.get_response(uri)
      assert response.code == '200', "Bundle resource not found at #{bundle_url}"
      bundle_resource = FHIR.from_contents(response.body)
      assert bundle_resource.resourceType == 'Bundle', 'Resource have different type than Bundle'
      scratch[:bundle_ips_resource] = bundle_resource
      info "Bundle resource saved to scratch: #{scratch_bundle}"
    end

    def skip_test?
      !((url.present? && bundle_id.present?) || bundle_url.present?)
    end

    def read_and_save_data
      if url.present? && bundle_id.present?
        get_bundle_resource_from_fhir_server(bundle_id) if url.present? && bundle_id.present?
      elsif bundle_url.present?
        get_bundle_resource_from_url(bundle_url)
      end
    end

    run do
      skip_if skip_test?, 'There is no FHIR server URL, Bundle ID or Bundle URL provided'
      read_and_save_data
      validate_ips_bundle
    end
  end
end
