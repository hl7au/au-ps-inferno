# frozen_string_literal: true

require_relative '../utils/basic_test/scratch_bundle_entries_module'
require_relative '../utils/common_inputs_module'

module AUPSTestKit
  # Automatically generated high order group for Retrieve AU PS Bundle validation tests
  class AUPSSuiteRetrieveAuPsBundleValidationTests < Inferno::TestGroup
    title 'Retrieve Bundle'
    description 'Retrieve document Bundle using Bundle read interaction or other HTTP GET request and verify response is valid AU PS Bundle'
    id :retrieve_bundle

    run_as_group

    test do
      include BasicTestScratchBundleEntriesModule

      title 'Retrieved Bundle is valid against AU PS Bundle profile'
      description 'Verifies that a bundle retrieved from the server conforms to the AU PS Bundle profile.'

      input_order :bundle_url, :url, :bundle_id, :credentials, :header_name, :header_value

      CommonInputsModule.shared_inputs(self)

      def scratch_bundle
        scratch[:bundle_ips_resource]
      end

      def metadata_manager
        @metadata_manager ||= MetadataManager.new(File.expand_path('../metadata.yaml', __dir__))
      end

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
end
