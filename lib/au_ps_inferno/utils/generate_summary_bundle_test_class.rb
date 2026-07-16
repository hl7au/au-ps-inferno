# frozen_string_literal: true

require 'net/http'
require 'uri'

require_relative 'basic_test_class'

module AUPSTestKit
  # Generates a Bundle via the IPS $summary operation into the group's scratch space
  class GenerateSummaryBundleTestClass < BasicTest
    id :generate_summary_bundle_test_class
    input_order :url, :patient_id, :identifier, :profile, :credentials, :header_name, :header_value

    NO_SUMMARY_INPUTS_MESSAGE = 'No FHIR server URL with patient id or patient identifier was provided, ' \
                                'so this test group is omitted.'

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

    input :patient_id,
          optional: true,
          description: 'To request Patient/{patient_id}/$summary'

    input :identifier,
          optional: true,
          description: 'To request Patient/$summary?identifier={identifier}'

    input :profile,
          optional: true,
          default: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle',
          description: 'To specify profile for the patient summary'

    fhir_client do
      url :url
      oauth_credentials :credentials
      headers(header_name.present? && header_value.present? ? { header_name => header_value } : {})
    end

    makes_request :summary_operation

    def skip_test?
      (patient_id.blank? && identifier.blank?) || url.blank?
    end

    def operation_path
      if patient_id
        profile ? "Patient/#{patient_id}/$summary?profile=#{profile}" : "Patient/#{patient_id}/$summary"
      elsif profile
        "Patient/$summary?identifier=#{identifier}&profile=#{profile}"
      else
        "Patient/$summary?identifier=#{identifier}"
      end
    end

    def read_and_save_data
      response = fhir_operation(operation_path, name: :summary_operation, operation_method: :get)
      assert_response_status(200)
      assert_resource_type(:bundle)
      resource_from_request = FHIR.from_contents(response.response_body)
      save_bundle_to_scratch(resource_from_request)
    end

    run do
      omit_if skip_test?, NO_SUMMARY_INPUTS_MESSAGE
      read_and_save_data
    end
  end
end
