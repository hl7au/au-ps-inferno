# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'

require_relative '../../../utils/summary_valid_bundle_class'


module AUPSTestKit
  # Automatically generated primitive test for Generated Bundle is valid against AU PS Bundle profile
  class AUPSSuite100ballotGenerateAuPsUsingIpsSummaryValidationTestsAuPsBundleValidationGeneratedBundleIsValidAgainstAuPsBundleProfile < SummaryValidBundleClass
    title 'Generated Bundle is valid against AU PS Bundle profile'
    description 'Verifies that a bundle produced by the IPS $summary operation conforms to the AU PS Bundle profile.'
    id :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_bundle_validation_bundle_valid
    
    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../1.0.0-ballot/metadata.yaml', __dir__))
    end
    
  end
end
