# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'

require_relative '../../../utils/generate_summary_bundle_test_class'

module AUPSTestKit
  # Automatically generated primitive test for Generate AU PS Bundle using the IPS $summary operation
  class AUPSSuiteGenerateAuPsUsingIpsSummaryValidationTestsBundleValidationGenerateAuPsBundleUsingTheIpsSummaryOperation < GenerateSummaryBundleTestClass
    title 'Generate AU PS Bundle using the IPS $summary operation'
    description 'Invokes the IPS $summary operation on the FHIR server and stores the returned Bundle ' \
                'for the validation tests in this group.'
    id :suite_generate_au_ps_using_ips_summary_validation_tests_bundle_validation_bundle_generate

    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../metadata.yaml', __dir__))
    end
  end
end
