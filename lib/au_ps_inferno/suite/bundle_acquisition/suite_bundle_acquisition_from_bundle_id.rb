# frozen_string_literal: true

require_relative '../../utils/basic_test_class'
require_relative '../../utils/bundle_acquisition_helpers'
require_relative '../../utils/common_inputs_module'
require_relative '../../utils/metadata_manager'

module AUPSTestKit
  # Retrieves the Bundle via a FHIR server Bundle read interaction (Bundle/{bundle_id}) and
  # stores it for every other group in the suite. Omitted in favor of $summary when a Patient ID
  # or Patient identifier is also given, matching the prior GenerateSummaryBundleTestClass
  # precedence.
  class AUPSSuiteBundleAcquisitionFromBundleId < BasicTest
    include BundleAcquisitionHelpers

    title 'Bundle acquired via Bundle ID'
    description 'Reads Bundle/{bundle_id} from the given FHIR server, expecting HTTP 200 with a ' \
                'Bundle resource. Omitted unless "FHIR Server" is selected and a Bundle ID is ' \
                'given without a Patient ID or Patient identifier (those take precedence).'
    id :suite_bundle_acquisition_from_bundle_id

    CommonInputsModule.bundle_acquisition_inputs(self)

    def metadata_manager
      @metadata_manager ||= CompositionMetadataManager.new(File.expand_path('../../metadata.yaml', __dir__))
    end

    run do
      omit_if bundle_retrieve_method != 'fhir_server' || bundle_id.blank? ||
              patient_id.present? || identifier.present?,
              'FHIR Server with a Bundle ID (and no Patient ID or Patient identifier) was not ' \
              'selected, so this test is omitted.'
      fhir_read(:bundle, bundle_id)
      assert_response_status(200)
      assert_resource_type(:bundle)
      info "Bundle was retrieved from #{url} via Bundle/#{bundle_id}."
      finish_acquisition(resource)
    end
  end
end
