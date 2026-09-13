# frozen_string_literal: true

require_relative '../../utils/basic_test_class'
require_relative '../../utils/bundle_acquisition_helpers'
require_relative '../../utils/common_inputs_module'
require_relative '../../utils/metadata_manager'

module AUPSTestKit
  # Retrieves the Bundle via a direct HTTP GET of the Bundle URL and stores it for every other
  # group in the suite.
  class AUPSSuiteBundleAcquisitionFromUrl < BasicTest
    include BundleAcquisitionHelpers

    title 'Bundle acquired from a Bundle URL'
    description 'Performs an HTTP GET against the given Bundle URL, expecting HTTP 200 with a ' \
                'parsable FHIR Bundle. Omitted unless "Bundle URL" is the selected Bundle ' \
                'Retrieval Method.'
    id :suite_bundle_acquisition_from_url

    CommonInputsModule.bundle_acquisition_inputs(self)

    def metadata_manager
      @metadata_manager ||= CompositionMetadataManager.new(File.expand_path('../../metadata.yaml', __dir__))
    end

    run do
      omit_if bundle_retrieve_method != 'bundle_url' || bundle_url.blank?,
              'Bundle URL was not selected as the Bundle Retrieval Method, so this test is omitted.'
      get(bundle_url, headers: extra_headers)
      assert_response_status(200)
      resource = parse_bundle(request.response_body)
      assert resource.present?, "The response from #{bundle_url} could not be parsed as a FHIR resource"
      assert resource.resourceType == 'Bundle',
             "The resource at #{bundle_url} is a #{resource.resourceType}, expected a Bundle"
      info "Bundle was retrieved via HTTP GET from #{bundle_url}."
      finish_acquisition(resource)
    end
  end
end
