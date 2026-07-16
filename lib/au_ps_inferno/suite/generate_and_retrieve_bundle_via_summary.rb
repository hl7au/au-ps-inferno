# frozen_string_literal: true

require_relative '../utils/basic_test/scratch_bundle_entries_module'
require_relative '../utils/common_inputs_module'

module AUPSTestKit
  # Automatically generated high order group for Generate AU PS using IPS $summary validation tests
  class GenerateAndRetrieveBundleViaSummary < Inferno::TestGroup
    title 'Generate and retrieve Bundle via $summary'
    description 'Generate AU Patient Summary using IPS $summary operation and verify response is valid AU PS Bundle'
    id :generate_and_retrieve_bundle_via_summary

    run_as_group

    test do
      include BasicTestScratchBundleEntriesModule

      title 'Generated Bundle is valid against AU PS Bundle profile'
      description 'Verifies that a bundle produced by the IPS $summary operation conforms to the AU PS Bundle profile.'

      input_order :url, :patient_id, :identifier, :profile, :credentials, :header_name, :header_value

      CommonInputsModule.shared_inputs(self)

      makes_request :summary_operation

      def metadata_manager
        @metadata_manager ||= MetadataManager.new(File.expand_path('../metadata.yaml', __dir__))
      end

      def scratch_bundle
        scratch[:bundle_ips_resource]
      end

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
end
