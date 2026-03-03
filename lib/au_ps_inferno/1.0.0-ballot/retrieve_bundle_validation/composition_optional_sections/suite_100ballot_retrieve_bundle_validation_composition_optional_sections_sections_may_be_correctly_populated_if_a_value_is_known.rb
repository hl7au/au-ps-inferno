# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'


module AUPSTestKit
  # Automatically generated primitive test for Sections MAY be correctly populated if a value is known
  class AUPSSuite100ballotRetrieveBundleValidationCompositionOptionalSectionsSectionsMayBeCorrectlyPopulatedIfAValueIsKnown < BasicTest
    title 'Sections MAY be correctly populated if a value is known'
    description ''
    id :suite_100ballot_retrieve_bundle_validation_composition_optional_sections_sections_may_be_correctly_populated_if_a_value_is_known
    
    optional
    
    
    run do
      
      validate_populated_sections_in_bundle(["42348-3", "104605-1", "47420-5", "11348-0", "10162-6", "81338-6", "18776-5", "29762-2", "8716-3"], ["title", "code", "text"])
      
    end
    
  end
end
