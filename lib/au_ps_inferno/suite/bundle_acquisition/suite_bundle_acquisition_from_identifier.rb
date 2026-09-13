# frozen_string_literal: true

require_relative '../../utils/basic_test_class'
require_relative '../../utils/bundle_acquisition_helpers'
require_relative '../../utils/common_inputs_module'
require_relative '../../utils/metadata_manager'

module AUPSTestKit
  # Retrieves the Bundle via the IPS $summary operation keyed by Patient identifier and stores
  # it for every other group in the suite. Takes precedence over Patient ID when both are given.
  class AUPSSuiteBundleAcquisitionFromIdentifier < BasicTest
    include BundleAcquisitionHelpers

    title 'Bundle acquired via Patient identifier ($summary)'
    description 'Calls Patient/$summary?identifier={identifier} on the given FHIR server. ' \
                'Omitted unless "FHIR Server" is selected and a Patient identifier is given. ' \
                'Runs instead of the Patient ID test when both are given.'
    id :suite_bundle_acquisition_from_identifier

    CommonInputsModule.bundle_acquisition_inputs(self)

    makes_request :summary_operation

    def metadata_manager
      @metadata_manager ||= CompositionMetadataManager.new(File.expand_path('../../metadata.yaml', __dir__))
    end

    run do
      omit_if bundle_retrieve_method != 'fhir_server' || identifier.blank?,
              'FHIR Server with a Patient identifier was not selected, so this test is omitted.'
      if patient_id.present?
        info 'Both Patient ID and Patient identifier were provided; Patient identifier search ' \
            'takes precedence and was used to populate the Inferno scratch.'
      end
      path = "Patient/$summary?identifier=#{identifier}&profile=#{AU_PS_BUNDLE_PROFILE}"
      response = fhir_operation(path, name: :summary_operation, operation_method: :get)
      assert_response_status(200)
      assert_resource_type(:bundle)
      info "Bundle was retrieved from #{url} via #{path}."
      finish_acquisition(FHIR.from_contents(response.response_body))
    end
  end
end
