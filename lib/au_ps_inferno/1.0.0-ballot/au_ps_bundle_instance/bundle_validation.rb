# frozen_string_literal: true



require_relative 'bundle_validation/suite_100ballot_au_ps_bundle_instance_bundle_validation_bundle_is_valid_against_au_ps_bundle_profile'


module AUPSTestKit
  # Automatically generated primitive group for Bundle Validation
  class AUPSSuite100ballotAuPsBundleInstanceBundleValidation < Inferno::TestGroup
    title 'Bundle Validation'
    description 'Validates that the bundle conforms to the AU PS Bundle profile.'
    id :suite_100ballot_au_ps_bundle_instance_bundle_validation
    
    
    run_as_group
    

    
    test from: :suite_100ballot_au_ps_bundle_instance_bundle_validation_bundle_is_valid_against_au_ps_bundle_profile
    
  end
end
