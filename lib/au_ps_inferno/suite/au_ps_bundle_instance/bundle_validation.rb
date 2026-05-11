# frozen_string_literal: true



require_relative 'bundle_validation/suite_100preview_au_ps_bundle_instance_bundle_validation_bundle_valid'

require_relative 'bundle_validation/suite_100preview_au_ps_bundle_instance_bundle_validation_bundle_valid_ips'


module AUPSTestKit
  # Automatically generated primitive group for Bundle Validation
  class AUPSSuite100previewAuPsBundleInstanceBundleValidation < Inferno::TestGroup
    title 'Bundle Validation'
    description 'Validates that the bundle conforms to the Bundle profiles.'
    id :suite_100preview_au_ps_bundle_instance_bundle_validation
    
    
    run_as_group
    

    
    test from: :suite_100preview_au_ps_bundle_instance_bundle_validation_bundle_valid
    
    test from: :suite_100preview_au_ps_bundle_instance_bundle_validation_bundle_valid_ips
    
  end
end
