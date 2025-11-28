# frozen_string_literal: true

require 'net/http'
require 'uri'

require_relative '../../../utils/basic_test_class'

module AUPSTestKit
  class AUPSRetrieveValidBundle < BasicTest
    id :au_ps_retrieve_valid_bundle
    title TEXTS[:au_ps_retrieve_valid_bundle][:title]
    description TEXTS[:au_ps_retrieve_valid_bundle][:description]

    input :bundle_id,
          optional: true,
          description: 'To request Bundle/{bundle_id}'

    input :bundle_url,
          optional: true,
          description: 'To request Patient/$summary?identifier={identifier}'

    def get_bundle_resource_from_fhir_server(bundle_id)
      info "Retrieving Bundle resource with id #{bundle_id}"
      fhir_read(:bundle, bundle_id)
      assert_response_status(200)
      assert_resource_type(:bundle)
      info "Bundle resource saved to scratch: #{resource.to_json}"
      scratch[:ips_bundle_resource] = resource
    end

    def get_bundle_resource_from_url(bundle_url)
      info "Retrieving Bundle resource from url #{bundle_url}"
      uri = URI(bundle_url)
      response = Net::HTTP.get_response(uri)
      assert response.code =="200", "Bundle resource not found at #{bundle_url}"
      bundle_resource = FHIR.from_contents(response.body)
      assert bundle_resource.resourceType == 'Bundle', "Resource have different type than Bundle"
      info "Bundle resource saved to scratch: #{bundle_resource.to_json}"
      scratch[:ips_bundle_resource] = bundle_resource
    end

    def skip_test?
      !((url.present? && bundle_id.present?) || (bundle_url.present?))
    end

    def get_and_save_data
      if url.present? && bundle_id.present?
        get_bundle_resource_from_fhir_server(bundle_id)
      end

      if bundle_url.present?
        get_bundle_resource_from_url(bundle_url)
      end
    end

    run do
      skip_if skip_test?, "There is no FHIR server URL, Bundle ID or Bundle URL provided"
      get_and_save_data
      validate_bundle(
        scratch[:ips_bundle_resource],
        'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle|0.4.0-draft')
    end
  end
end
