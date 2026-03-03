# frozen_string_literal: true



require_relative 'bundle_validation/suite_100ballot_generated_bundle_ips_summary_bundle_validation_generated_bundle_is_valid_against_au_ps_bundle_profile'


module AUPSTestKit
  # Automatically generated primitive group for Bundle Validation
  class AUPSSuite100ballotGeneratedBundleIpsSummaryBundleValidation < Inferno::TestGroup
    title 'Bundle Validation'
    description 'Validates that the bundle conforms to the AU PS Bundle profile.'
    id :suite_100ballot_generated_bundle_ips_summary_bundle_validation

    
    test from: :suite_100ballot_generated_bundle_ips_summary_bundle_validation_generated_bundle_is_valid_against_au_ps_bundle_profile
    
  end
end
