# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'


module AUPSTestKit
  # Automatically generated primitive test for Mandatory Must Support element SHALL be able to be populated if a value is known and allowed to share
  class AUPSSuite100ballotAuPsBundleInstanceCompositionMustSupportElementsMandatoryMustSupportElementShallBeAbleToBePopulatedIfAValueIsKnownAndAllowedToShare < BasicTest
    title 'Mandatory Must Support element SHALL be able to be populated if a value is known and allowed to share'
    description ''
    id :suite_100ballot_au_ps_bundle_instance_composition_must_support_elements_mandatory_must_support_element_shall_be_able_to_be_populated_if_a_value_is_known_and_allowed_to_share
    
    run do
      
      validate_populated_elements_in_composition(["author", "date", "section", "status", "subject", "title", "type"])
      
    end
    
  end
end
