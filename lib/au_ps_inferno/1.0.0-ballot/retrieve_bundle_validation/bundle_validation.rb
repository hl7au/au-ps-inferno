# frozen_string_literal: true



require_relative 'bundle_validation/suite_100ballot_retrieve_bundle_validation_bundle_validation_retrieved_bundle_is_valid_against_au_ps_bundle_profile'


module AUPSTestKit
  # Automatically generated primitive group for Bundle Validation
  class AUPSSuite100ballotRetrieveBundleValidationBundleValidation < Inferno::TestGroup
    title 'Bundle Validation'
    description 'Displays information about Bundle Validation in the Composition resource.'
    id :suite_100ballot_retrieve_bundle_validation_bundle_validation

    
    test from: :suite_100ballot_retrieve_bundle_validation_bundle_validation_retrieved_bundle_is_valid_against_au_ps_bundle_profile
    
  end
end
