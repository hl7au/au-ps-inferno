# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'

require_relative '../../../utils/bundle_is_valid_class'


module AUPSTestKit
  # Automatically generated primitive test for AU PS Bundle is valid against AU PS Bundle profile
  class AUPSSuite100ballotAuPsBundleInstanceAuPsBundleValidationAuPsBundleIsValidAgainstAuPsBundleProfile < BundleIsValidClass
    title 'AU PS Bundle is valid against AU PS Bundle profile'
    description 'The Bundle resource is valid against the AU PS Bundle profile using FHIR validator'
    id :suite_100ballot_au_ps_bundle_instance_au_ps_bundle_validation_bundle_valid
    
    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../1.0.0-ballot/metadata.yaml', __dir__))
    end
    
  end
end
