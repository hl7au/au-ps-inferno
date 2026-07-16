# frozen_string_literal: true

require 'net/http'
require 'uri'

require_relative 'basic_validate_bundle_test'

module AUPSTestKit
  # A base class for all tests that retrieve a Bundle resource
  class RetrieveBundleTestClass < BasicValidateBundleTest
    id :retrieve_bundle_test_class

    def get_bundle_resource_from_fhir_server(bundle_id)
      fhir_read(:bundle, bundle_id)
      assert_response_status(200)
      assert_resource_type(:bundle)
      scratch[:bundle_ips_resource] = resource
    end

    def get_bundle_resource_from_url(bundle_url)
      uri = URI(bundle_url)
      response = Net::HTTP.get_response(uri)
      assert response.code == '200', "Bundle resource not found at #{bundle_url}"
      bundle_resource = FHIR.from_contents(response.body)
      assert bundle_resource.resourceType == 'Bundle', 'Resource have different type than Bundle'
      scratch[:bundle_ips_resource] = bundle_resource
      save_bundle_entities_to_scratch(scratch_bundle)
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
      omit_if skip_test?, 'There is no FHIR server URL, Bundle ID or Bundle URL provided'
      read_and_save_data
    end
  end
end
