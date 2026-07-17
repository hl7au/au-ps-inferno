# frozen_string_literal: true

require_relative '../../utils/basic_test_class'
require_relative '../../utils/metadata_manager'

require_relative '../../utils/retrieve_bundle_test_class'

module AUPSTestKit
  # Retrieves the AU PS Bundle from the FHIR server, gated on the 'url' retrieval method being selected
  class AUPSSuiteAuPsBundleInstanceBundleAcquisitionRetrieveAuPsBundle < RetrieveBundleTestClass
    title 'Retrieve AU PS Bundle from the FHIR server'
    description 'A Bundle can be retrieved via a Bundle read interaction (FHIR server URL and Bundle ID) or a ' \
                'direct HTTP GET of the Bundle URL, returning HTTP 200 with a parsable FHIR Bundle. The ' \
                'retrieved Bundle is stored for the validation tests in this group.'
    id :suite_au_ps_bundle_instance_bundle_retrieve

    def skip_test?
      retrieval_method != 'url' || super
    end

    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../metadata.yaml', __dir__))
    end
  end
end
