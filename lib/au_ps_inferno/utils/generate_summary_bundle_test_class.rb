# frozen_string_literal: true

require_relative 'basic_test_class'
require_relative 'common_inputs_module'

module AUPSTestKit
  # Retrieves a Bundle from a FHIR server, either via the IPS $summary operation
  # (patient_id/identifier) or a Bundle read interaction (bundle_id), into the
  # group's scratch space
  class GenerateSummaryBundleTestClass < BasicTest
    id :generate_summary_bundle_test_class

    NO_SUMMARY_INPUTS_MESSAGE = 'No FHIR server URL with a Bundle ID, patient ID, or patient identifier was ' \
                                'provided, so this test group is omitted.'

    AU_PS_BUNDLE_PROFILE = 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle'

    CommonInputsModule.fhir_server_inputs(self)

    makes_request :summary_operation

    def summary_data_available?
      url.present? && (patient_id.present? || identifier.present?)
    end

    def bundle_by_id_available?
      url.present? && bundle_id.present?
    end

    def skip_test?
      !(summary_data_available? || bundle_by_id_available?)
    end

    def get_bundle_resource_from_fhir_server(bundle_id)
      fhir_read(:bundle, bundle_id)
      assert_response_status(200)
      assert_resource_type(:bundle)
      save_bundle_to_scratch(resource)
    end

    def operation_path
      if patient_id
        "Patient/#{patient_id}/$summary?profile=#{AU_PS_BUNDLE_PROFILE}"
      else
        "Patient/$summary?identifier=#{identifier}&profile=#{AU_PS_BUNDLE_PROFILE}"
      end
    end

    def read_and_save_data_from_summary
      response = fhir_operation(operation_path, name: :summary_operation, operation_method: :get)
      assert_response_status(200)
      assert_resource_type(:bundle)
      resource_from_request = FHIR.from_contents(response.response_body)
      save_bundle_to_scratch(resource_from_request)
    end

    def read_and_save_data
      if summary_data_available?
        read_and_save_data_from_summary
      elsif bundle_by_id_available?
        get_bundle_resource_from_fhir_server(bundle_id)
      end
    end

    run do
      omit_if skip_test?, NO_SUMMARY_INPUTS_MESSAGE
      read_and_save_data
    end
  end
end
