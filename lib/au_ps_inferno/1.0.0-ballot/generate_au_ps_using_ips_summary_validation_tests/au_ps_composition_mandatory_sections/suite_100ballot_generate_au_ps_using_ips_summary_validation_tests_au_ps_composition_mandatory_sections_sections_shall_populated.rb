# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'


module AUPSTestKit
  # Automatically generated primitive test for AU PS Composition Mandatory Sections are correctly populated
  class AUPSSuite100ballotGenerateAuPsUsingIpsSummaryValidationTestsAuPsCompositionMandatorySectionsAuPsCompositionMandatorySectionsAreCorrectlyPopulated < BasicTest
    title 'AU PS Composition Mandatory Sections are correctly populated'
    description 'Mandatory section SHALL be correctly populated if a value is known'
    id :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_mandatory_sections_sections_shall_populated
    
    
    run do
      
      validate_populated_sections_in_bundle(["11450-4", "48765-2", "10160-0"], ["title", "code", "text"])
      
    end
    
  end
end
