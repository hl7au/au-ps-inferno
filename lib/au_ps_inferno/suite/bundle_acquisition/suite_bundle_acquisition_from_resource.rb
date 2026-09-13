# frozen_string_literal: true

require_relative '../../utils/basic_test_class'
require_relative '../../utils/bundle_acquisition_helpers'
require_relative '../../utils/common_inputs_module'
require_relative '../../utils/metadata_manager'

module AUPSTestKit
  # Loads the Bundle resource pasted as text and stores it for every other group in the suite.
  class AUPSSuiteBundleAcquisitionFromResource < BasicTest
    include BundleAcquisitionHelpers

    title 'Bundle acquired from a pasted resource'
    description 'The provided text can be parsed as a FHIR resource (JSON or XML) and its ' \
                'resourceType is Bundle. Omitted unless "Bundle Resource" is the selected Bundle ' \
                'Retrieval Method.'
    id :suite_bundle_acquisition_from_resource

    CommonInputsModule.bundle_acquisition_inputs(self)

    def metadata_manager
      @metadata_manager ||= CompositionMetadataManager.new(File.expand_path('../../metadata.yaml', __dir__))
    end

    run do
      omit_if bundle_retrieve_method != 'bundle_resource' || bundle_resource.blank?,
              'Bundle Resource was not selected as the Bundle Retrieval Method, so this test is omitted.'
      resource = parse_bundle(bundle_resource)
      assert resource.present?, 'The provided text could not be parsed as a FHIR resource'
      assert resource.resourceType == 'Bundle',
             "The provided resource is a #{resource.resourceType}, expected a Bundle"
      info 'Bundle was provided as a pasted FHIR resource.'
      finish_acquisition(resource)
    end
  end
end
