# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'

require_relative '../../../utils/retrieve_bundle_test_class'

require_relative '../../../utils/ips_retrieve_bundle_test_class'


module AUPSTestKit
  # Automatically generated primitive test for Retrieved Bundle is valid against IPS Bundle profile
  class AUPSSuite100previewRetrieveAuPsBundleValidationTestsBundleValidationRetrievedBundleIsValidAgainstIpsBundleProfile < IpsRetrieveBundleTestClass
    title 'Retrieved Bundle is valid against IPS Bundle profile'
    description 'Verifies that a bundle retrieved from the server conforms to the IPS Bundle profile.'
    id :suite_100preview_retrieve_au_ps_bundle_validation_tests_bundle_validation_bundle_valid_ips
    
    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../../metadata.yaml', __dir__))
    end
    
  end
end
