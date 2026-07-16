# frozen_string_literal: true

require 'net/http'
require 'uri'

require_relative 'basic_validate_bundle_test'

module AUPSTestKit
  # The Bundle resource is valid against the AU PS Bundle profile
  class SummaryValidBundleClass < BasicValidateBundleTest
    id :summary_valid_bundle_class_test
    input_order :url, :patient_id, :identifier, :profile, :credentials, :header_name, :header_value

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
      scratch[:bundle_ips_resource] = resource_from_request
      save_bundle_entities_to_scratch(scratch_bundle)
    end

    run do
      omit_if url.blank?, 'No FHIR server specified'
      summary_op_defined? if scratch[:summary_op_defined].blank?
      skip_if scratch[:summary_op_defined] == false, 'Server does not declare support for $summary operation'
      read_and_save_data
    end
  end
end
