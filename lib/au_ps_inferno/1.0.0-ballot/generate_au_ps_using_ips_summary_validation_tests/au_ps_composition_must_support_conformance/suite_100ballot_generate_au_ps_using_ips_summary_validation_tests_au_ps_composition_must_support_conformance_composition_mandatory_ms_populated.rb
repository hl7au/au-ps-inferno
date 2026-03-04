# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'


module AUPSTestKit
  # Automatically generated primitive test for Mandatory Must Support element SHALL be able to be populated if a value is known and allowed to share
  class AUPSSuite100ballotGenerateAuPsUsingIpsSummaryValidationTestsAuPsCompositionMustSupportConformanceMandatoryMustSupportElementShallBeAbleToBePopulatedIfAValueIsKnownAndAllowedToShare < BasicTest
    title 'Mandatory Must Support element SHALL be able to be populated if a value is known and allowed to share'
    description 'Verifies that mandatory Must Support elements in the Composition can be populated when data is known and shareable.'
    id :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_must_support_conformance_composition_mandatory_ms_populated
    
    
    run do
      
      validate_populated_elements_in_composition(["author", "date", "section", "status", "subject", "title", "type"])
      
    end
    
  end
end
