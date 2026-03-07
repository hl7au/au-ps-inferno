# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'


module AUPSTestKit
  # Automatically generated primitive test for AU PS Composition optional sections are correctly populated
  class AUPSSuite100ballotGenerateAuPsUsingIpsSummaryValidationTestsAuPsCompositionOptionalSectionsAuPsCompositionOptionalSectionsAreCorrectlyPopulated < BasicTest
    title 'AU PS Composition optional sections are correctly populated'
    description 'Optional section MAY be correctly populated if a value is known'
    id :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_optional_sections_sections_may_populated
    
    
    run do
      
      validate_populated_sections_in_bundle(["42348-3", "104605-1", "47420-5", "11348-0", "10162-6", "81338-6", "18776-5", "29762-2", "8716-3"], ["title", "code", "text"])
      
    end
    
  end
end
