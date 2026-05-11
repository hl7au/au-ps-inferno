# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'

module AUPSTestKit
  # Automatically generated primitive test for Must Support identifier slices SHALL be populated if a value is known
  class AUPSSuite100previewGenerateAuPsUsingIpsSummaryValidationTestsAuPsCompositionAuthorMustSupportIdentifierSlicesShallBePopulatedIfAValueIsKnown < BasicTest
    title 'Must Support identifier slices SHALL be populated if a value is known'
    description 'Must Support identifier slices SHALL be populated if a value is known'
    id :suite_100preview_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_author_author_ms_identifier_slices

    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../metadata.yaml', __dir__))
    end

    run do
      test_composition_author_ms_identifier_slices
    end
  end
end
