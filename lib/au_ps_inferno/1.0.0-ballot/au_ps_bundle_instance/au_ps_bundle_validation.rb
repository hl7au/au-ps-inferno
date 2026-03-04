# frozen_string_literal: true



require_relative 'au_ps_bundle_validation/suite_100ballot_au_ps_bundle_instance_au_ps_bundle_validation_au_ps_bundle_must_support_elements_are_correctly_populated'


module AUPSTestKit
  # Automatically generated primitive group for AU PS Bundle Validation
  class AUPSSuite100ballotAuPsBundleInstanceAuPsBundleValidation < Inferno::TestGroup
    title 'AU PS Bundle Validation'
    description 'Validates that the bundle conforms to the AU PS Bundle profile.'
    id :suite_100ballot_au_ps_bundle_instance_au_ps_bundle_validation
    
    
    run_as_group
    

    
    test from: :suite_100ballot_au_ps_bundle_instance_au_ps_bundle_validation_au_ps_bundle_must_support_elements_are_correctly_populated
    
  end
end
