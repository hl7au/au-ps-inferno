# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'

require_relative '../../../utils/summary_valid_bundle_class'

require_relative '../../../utils/ips_summary_valid_bundle_class'


module AUPSTestKit
  # Automatically generated primitive test for Generated Bundle resource is a valid IPS
  class AUPSSuite100previewGenerateAuPsUsingIpsSummaryValidationTestsPatientSummaryBundleValidationTestsGeneratedBundleResourceIsAValidIps < IpsSummaryValidBundleClass
    title 'Generated Bundle resource is a valid IPS'
    description 'Verifies that a Bundle produced by the IPS $summary operation conforms to the IPS profiles.'
    id :suite_100preview_generate_au_ps_using_ips_summary_validation_tests_patient_summary_bundle_validation_tests_bundle_valid_ips
    
    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../1.0.0-preview/metadata.yaml', __dir__))
    end
    
  end
end
