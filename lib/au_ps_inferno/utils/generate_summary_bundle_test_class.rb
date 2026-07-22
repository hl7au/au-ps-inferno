# frozen_string_literal: true

require_relative 'basic_test_class'
require_relative 'common_inputs_module'

module AUPSTestKit
  # Generates a Bundle via the IPS $summary operation into the group's scratch space
  class GenerateSummaryBundleTestClass < BasicTest
    id :generate_summary_bundle_test_class
    input_order :url, :patient_id, :identifier, :profile, :credentials, :header_name, :header_value

    NO_SUMMARY_INPUTS_MESSAGE = 'No FHIR server URL with patient id or patient identifier was provided, ' \
                                'so this test group is omitted.'

    CommonInputsModule.summary_inputs(self)
    CommonInputsModule.shared_inputs(self)

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
