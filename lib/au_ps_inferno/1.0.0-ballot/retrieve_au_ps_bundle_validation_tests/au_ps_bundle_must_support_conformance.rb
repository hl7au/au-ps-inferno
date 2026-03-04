# frozen_string_literal: true



require_relative 'au_ps_bundle_must_support_conformance/suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_bundle_must_support_conformance_must_support_elements_shall_be_populated_when_an_element_value_is_known_and_allowed_to_share'


module AUPSTestKit
  # Automatically generated primitive group for AU PS Bundle Must Support Conformance
  class AUPSSuite100ballotRetrieveAuPsBundleValidationTestsAuPsBundleMustSupportConformance < Inferno::TestGroup
    title 'AU PS Bundle Must Support Conformance'
    description 'Verifies that Must Support elements at the bundle level are populated when data is available.'
    id :suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_bundle_must_support_conformance
    
    
    run_as_group
    

    
    test from: :suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_bundle_must_support_conformance_must_support_elements_shall_be_populated_when_an_element_value_is_known_and_allowed_to_share
    
  end
end
