# frozen_string_literal: true

require_relative '../../utils/basic_test_class'
require_relative '../../utils/metadata_manager'

require_relative '../../utils/generate_summary_bundle_test_class'

module AUPSTestKit
  # Generates the AU PS Bundle via the IPS $summary operation, gated on the 'summary_op' retrieval method
  # being selected
  class AUPSSuiteAuPsBundleInstanceBundleAcquisitionGenerateAuPsBundleViaSummary < GenerateSummaryBundleTestClass
    title 'Generate AU PS Bundle via $summary'
    description 'The IPS $summary operation returns HTTP 200 with a Bundle. The generated Bundle is stored for ' \
                'the validation tests in this group.'
    id :suite_au_ps_bundle_instance_bundle_summary

    def skip_test?
      retrieval_method != 'summary_op' || super
    end

    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../metadata.yaml', __dir__))
    end
  end
end
