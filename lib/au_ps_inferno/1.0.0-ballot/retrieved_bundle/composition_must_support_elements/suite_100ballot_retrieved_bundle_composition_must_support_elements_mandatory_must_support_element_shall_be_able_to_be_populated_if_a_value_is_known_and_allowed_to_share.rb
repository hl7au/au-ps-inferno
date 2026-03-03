# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'


module AUPSTestKit
  # Automatically generated primitive test for Mandatory Must Support element SHALL be able to be populated if a value is known and allowed to share
  class AUPSSuite100ballotRetrievedBundleCompositionMustSupportElementsMandatoryMustSupportElementShallBeAbleToBePopulatedIfAValueIsKnownAndAllowedToShare < BasicTest
    title 'Mandatory Must Support element SHALL be able to be populated if a value is known and allowed to share'
    description 'Verifies that mandatory Must Support elements in the Composition can be populated when data is known and shareable.'
    id :suite_100ballot_retrieved_bundle_composition_must_support_elements_mandatory_must_support_element_shall_be_able_to_be_populated_if_a_value_is_known_and_allowed_to_share
    
    
    run do
      
      validate_populated_elements_in_composition(["author", "date", "section", "status", "subject", "title", "type"])
      
    end
    
  end
end
