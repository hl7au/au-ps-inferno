# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'


module AUPSTestKit
  # Automatically generated primitive test for Sections SHOULD be correctly populated if a value is known
  class AUPSSuite100ballotAuPsBundleInstanceAuPsCompositionRecommendedSectionsSectionsShouldBeCorrectlyPopulatedIfAValueIsKnown < BasicTest
    title 'Sections SHOULD be correctly populated if a value is known'
    description 'Verifies that recommended sections are correctly populated when data is known.'
    id :suite_100ballot_au_ps_bundle_instance_au_ps_composition_recommended_sections_sections_should_populated
    
    optional
    
    
    run do
      
      validate_populated_sections_in_bundle(["11369-6", "30954-2", "47519-4", "46264-8"], ["title", "code", "text"])
      
    end
    
  end
end
