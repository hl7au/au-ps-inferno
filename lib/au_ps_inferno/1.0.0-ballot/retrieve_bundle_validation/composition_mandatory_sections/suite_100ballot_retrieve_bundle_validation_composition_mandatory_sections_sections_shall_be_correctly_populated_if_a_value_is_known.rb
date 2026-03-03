# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'


module AUPSTestKit
  # Automatically generated primitive test for Sections SHALL be correctly populated if a value is known
  class AUPSSuite100ballotRetrieveBundleValidationCompositionMandatorySectionsSectionsShallBeCorrectlyPopulatedIfAValueIsKnown < BasicTest
    title 'Sections SHALL be correctly populated if a value is known'
    description ''
    id :suite_100ballot_retrieve_bundle_validation_composition_mandatory_sections_sections_shall_be_correctly_populated_if_a_value_is_known
    
    
    run do
      
      validate_populated_sections_in_bundle(["11450-4", "48765-2", "10160-0"], ["title", "code", "text"])
      
    end
    
  end
end
