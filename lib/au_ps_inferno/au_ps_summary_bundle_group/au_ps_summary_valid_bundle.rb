# frozen_string_literal: true

require 'net/http'
require 'uri'

require_relative '../utils/basic_test_class'

module AUPSTestKit
  # The Bundle resource is valid against the AU PS Bundle profile
  class AUPSSummaryValidBundle < BasicTest
    id :au_ps_summary_valid_bundle
    title 'Server generates AU Patient Summary using IPS $summary operation'
    description 'Generate AU Patient Summary using IPS $summary operation and verify response is valid ' \
      'AU PS Bundle'

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
        if profile
          "Patient/#{patient_id}/$summary?profile=#{profile}"
        else
          "Patient/#{patient_id}/$summary"
        end
      else
        if profile
          "Patient/$summary?identifier=#{identifier}&profile=#{profile}"
        else
          "Patient/$summary?identifier=#{identifier}"
        end
      end
    end

    def read_and_save_data
      info 'Making $summary operation request'
      response = fhir_operation(operation_path, name: :summary_operation, operation_method: :get)
      resource_from_request = FHIR.from_contents(response.response_body)
      scratch[:bundle_ips_resource] = resource_from_request
      info "Bundle resource saved to scratch: #{scratch_bundle}"
    end

    run do
      skip_if url.blank?, 'No FHIR server specified'
      summary_op_defined? if scratch[:summary_op_defined].blank?
      skip_if scratch[:summary_op_defined] == false, 'Server does not declare support for $summary operation'
      read_and_save_data
      validate_ips_bundle
    end
  end
end
