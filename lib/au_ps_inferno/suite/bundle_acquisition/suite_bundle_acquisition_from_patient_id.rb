# frozen_string_literal: true

require_relative '../../utils/basic_test_class'
require_relative '../../utils/bundle_acquisition_helpers'
require_relative '../../utils/common_inputs_module'
require_relative '../../utils/metadata_manager'

module AUPSTestKit
  # Retrieves the Bundle via the IPS $summary operation keyed by Patient ID and stores it for
  # every other group in the suite. Omitted in favor of the Patient identifier test when both are
  # given.
  class AUPSSuiteBundleAcquisitionFromPatientId < BasicTest
    include BundleAcquisitionHelpers

    title 'Bundle acquired via Patient ID ($summary)'
    description 'Calls Patient/{patient_id}/$summary on the given FHIR server. Omitted unless ' \
                '"FHIR Server" is selected, a Patient ID is given, and no Patient identifier is ' \
                'given (Patient identifier takes precedence when both are present).'
    id :suite_bundle_acquisition_from_patient_id

    CommonInputsModule.bundle_acquisition_inputs(self)

    makes_request :summary_operation

    def metadata_manager
      @metadata_manager ||= CompositionMetadataManager.new(File.expand_path('../../metadata.yaml', __dir__))
    end

    run do
      omit_if bundle_retrieve_method != 'fhir_server' || patient_id.blank? || identifier.present?,
              'FHIR Server with a Patient ID (and no Patient identifier) was not selected, so ' \
              'this test is omitted.'
      path = "Patient/#{patient_id}/$summary?profile=#{AU_PS_BUNDLE_PROFILE}"
      response = fhir_operation(path, name: :summary_operation, operation_method: :get)
      assert_response_status(200)
      assert_resource_type(:bundle)
      info "Bundle was retrieved from #{url} via #{path}."
      finish_acquisition(FHIR.from_contents(response.response_body))
    end
  end
end
