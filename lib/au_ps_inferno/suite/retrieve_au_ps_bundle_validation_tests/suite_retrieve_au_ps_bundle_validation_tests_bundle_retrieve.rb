# frozen_string_literal: true

require_relative '../../utils/basic_test_class'
require_relative '../../utils/metadata_manager'

require_relative '../../utils/retrieve_bundle_test_class'

module AUPSTestKit
  # Automatically generated primitive test for Bundle is retrievable from the FHIR server
  class AUPSSuiteRetrieveAuPsBundleValidationTestsBundleValidationRetrieveAuPsBundleFromTheFhirServer < RetrieveBundleTestClass
    title 'Bundle is retrievable from the FHIR server'
    description 'A Bundle can be retrieved via a Bundle read interaction (FHIR server URL and Bundle ID) or a ' \
                'direct HTTP GET of the Bundle URL, returning HTTP 200 with a parsable FHIR Bundle. The ' \
                'retrieved Bundle is stored for the validation tests in this group.'
    id :suite_retrieve_au_ps_bundle_validation_tests_bundle_retrieve

    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../metadata.yaml', __dir__))
    end
  end
end
