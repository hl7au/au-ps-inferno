# frozen_string_literal: true



require_relative 'au_ps_bundle_validation/suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_bundle_validation_retrieved_bundle_is_valid_against_au_ps_bundle_profile'


module AUPSTestKit
  # Automatically generated primitive group for AU PS Bundle Validation
  class AUPSSuite100ballotRetrieveAuPsBundleValidationTestsAuPsBundleValidation < Inferno::TestGroup
    title 'AU PS Bundle Validation'
    description 'Validates that the bundle conforms to the AU PS Bundle profile.'
    id :suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_bundle_validation
    
    
    run_as_group
    

    
    test from: :suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_bundle_validation_retrieved_bundle_is_valid_against_au_ps_bundle_profile
    
  end
end
