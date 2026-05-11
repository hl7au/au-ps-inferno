# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'

require_relative '../../../utils/summary_valid_bundle_class'

require_relative '../../../utils/ips_summary_valid_bundle_class'

module AUPSTestKit
  # Automatically generated primitive test for Generated Bundle is valid against IPS Bundle profile
  class AUPSSuite100previewGenerateAuPsUsingIpsSummaryValidationTestsBundleValidationGeneratedBundleIsValidAgainstIpsBundleProfile < IpsSummaryValidBundleClass
    title 'Generated Bundle is valid against IPS Bundle profile'
    description 'Verifies that a bundle produced by the IPS $summary operation conforms to the IPS Bundle profile.'
    id :suite_100preview_generate_au_ps_using_ips_summary_validation_tests_bundle_validation_bundle_valid_ips

    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../metadata.yaml', __dir__))
    end
  end
end
