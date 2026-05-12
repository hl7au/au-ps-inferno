# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'


module AUPSTestKit
  # Automatically generated primitive test for Undefined sections are correctly populated
  class AUPSSuite100previewGenerateAuPsUsingIpsSummaryValidationTestsAuPsCompositionUndefinedSectionsUndefinedSectionsAreCorrectlyPopulated < BasicTest
    title 'Undefined sections are correctly populated'
    description 'Undefined sections MAY be populated if a value is known'
    id :suite_100preview_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_undefined_sections_sections_may_undefined
    
    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../1.0.0-preview/metadata.yaml', __dir__))
    end
    
    run do
      
      validate_populated_undefined_sections_in_bundle(["11450-4", "48765-2", "10160-0", "11369-6", "30954-2", "47519-4", "46264-8", "42348-3", "104605-1", "47420-5", "11348-0", "10162-6", "81338-6", "18776-5", "29762-2", "8716-3"], ["title", "code", "text"])
      
    end
    
  end
end
