# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'

require_relative '../../../utils/retrieve_bundle_test_class'

require_relative '../../../utils/ips_retrieve_bundle_test_class'


module AUPSTestKit
  # Automatically generated primitive test for Retrieved Bundle resource is a valid AU Patient Summary
  class AUPSSuite100previewRetrieveAuPsBundleValidationTestsPatientSummaryBundleValidationTestsRetrievedBundleResourceIsAValidAuPatientSummary < RetrieveBundleTestClass
    title 'Retrieved Bundle resource is a valid AU Patient Summary'
    description 'Verifies that a Bundle retrieved from the server conforms to the AU PS profiles.'
    id :suite_100preview_retrieve_au_ps_bundle_validation_tests_patient_summary_bundle_validation_tests_bundle_valid
    
    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../1.0.0-preview/metadata.yaml', __dir__))
    end
    
  end
end
