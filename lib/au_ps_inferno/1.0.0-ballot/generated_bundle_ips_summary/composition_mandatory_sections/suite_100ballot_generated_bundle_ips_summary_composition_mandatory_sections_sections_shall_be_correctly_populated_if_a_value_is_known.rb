# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'


module AUPSTestKit
  # Automatically generated primitive test for Sections SHALL be correctly populated if a value is known
  class AUPSSuite100ballotGeneratedBundleIpsSummaryCompositionMandatorySectionsSectionsShallBeCorrectlyPopulatedIfAValueIsKnown < BasicTest
    title 'Sections SHALL be correctly populated if a value is known'
    description 'Verifies that mandatory sections are correctly populated when data is known.'
    id :suite_100ballot_generated_bundle_ips_summary_composition_mandatory_sections_sections_shall_be_correctly_populated_if_a_value_is_known
    
    
    run do
      
      validate_populated_sections_in_bundle(["11450-4", "48765-2", "10160-0"], ["title", "code", "text"])
      
    end
    
  end
end
