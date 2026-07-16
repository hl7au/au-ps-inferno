# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'

require_relative '../../../utils/bundle_is_valid_class'

module AUPSTestKit
  # Automatically generated primitive test for Retrieved Bundle is valid against AU PS Bundle profile
  class AUPSSuiteRetrieveAuPsBundleValidationTestsBundleValidationRetrievedBundleIsValidAgainstAuPsBundleProfile < BundleIsValidClass
    title 'Retrieved Bundle is valid against AU PS Bundle profile'
    description 'Verifies that the bundle retrieved from the server conforms to the AU PS Bundle profile.'
    id :suite_retrieve_au_ps_bundle_validation_tests_bundle_validation_bundle_valid

    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../metadata.yaml', __dir__))
    end
  end
end
