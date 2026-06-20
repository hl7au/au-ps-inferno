# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'

require_relative '../../../utils/bundle_is_valid_class'

require_relative '../../../utils/ips_bundle_is_valid_class'


module AUPSTestKit
  # Automatically generated primitive test for Bundle resource is a valid AU Patient Summary
  class AUPSSuite100previewAuPsBundleInstancePatientSummaryBundleValidationTestsBundleResourceIsAValidAuPatientSummary < BundleIsValidClass
    title 'Bundle resource is a valid AU Patient Summary'
    description 'The Bundle resource is valid against the AU PS profiles using FHIR validator'
    id :suite_100preview_au_ps_bundle_instance_patient_summary_bundle_validation_tests_bundle_valid
    
    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../1.0.0-preview/metadata.yaml', __dir__))
    end
    
  end
end
