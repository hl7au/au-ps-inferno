# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'


module AUPSTestKit
  # Automatically generated primitive test for AU PS Composition recommended sections are correctly populated
  class AUPSSuite100ballotRetrieveAuPsBundleValidationTestsAuPsCompositionRecommendedSectionsAuPsCompositionRecommendedSectionsAreCorrectlyPopulated < BasicTest
    title 'AU PS Composition recommended sections are correctly populated'
    description 'Recommended sections SHOULD be correctly populated if a value is known'
    id :suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_composition_recommended_sections_sections_should_populated
    
    
    run do
      
      validate_populated_sections_in_bundle(["11369-6", "30954-2", "47519-4", "46264-8"], ["title", "code", "text"])
      
    end
    
  end
end
