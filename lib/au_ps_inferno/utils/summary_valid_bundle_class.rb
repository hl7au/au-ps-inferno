# frozen_string_literal: true

require 'net/http'
require 'uri'

require_relative 'basic_validate_bundle_test'

module AUPSTestKit
  # The Bundle resource is valid against the AU PS Bundle profile
  class SummaryValidBundleClass < BasicValidateBundleTest
    id :summary_valid_bundle_class_test
    input_order :url, :patient_id, :identifier, :profile, :credentials, :header_name, :header_value

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
      info 'Making $summary operation request'
      response = fhir_operation(operation_path, name: :summary_operation, operation_method: :get)
      assert_response_status(200)
      assert_resource_type(:bundle)
      resource_from_request = FHIR.from_contents(response.response_body)
      scratch[:bundle_ips_resource] = resource_from_request
      save_bundle_entities_to_scratch(scratch_bundle)
      info "Bundle resource saved to scratch: #{scratch_bundle}"
    end

    run do
      skip_if url.blank?, 'No FHIR server specified'
      summary_op_defined? if scratch[:summary_op_defined].blank?
      skip_if scratch[:summary_op_defined] == false, 'Server does not declare support for $summary operation'
      read_and_save_data
      omit_if omit_au_ps_validation?, OMIT_AU_PS_MESSAGE
      validate_au_ps_bundle
    end
  end
end
