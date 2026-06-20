# frozen_string_literal: true



require_relative 'patient_summary_bundle_validation_tests/suite_100preview_generate_au_ps_using_ips_summary_validation_tests_patient_summary_bundle_validation_tests_bundle_valid'

require_relative 'patient_summary_bundle_validation_tests/suite_100preview_generate_au_ps_using_ips_summary_validation_tests_patient_summary_bundle_validation_tests_bundle_valid_ips'


module AUPSTestKit
  # Automatically generated primitive group for Patient Summary Bundle Validation Tests
  class AUPSSuite100previewGenerateAuPsUsingIpsSummaryValidationTestsPatientSummaryBundleValidationTests < Inferno::TestGroup
    title 'Patient Summary Bundle Validation Tests'
    description 'Validates that the Bundle resource conforms to the AU Patient Summary profiles.'
    id :suite_100preview_generate_au_ps_using_ips_summary_validation_tests_patient_summary_bundle_validation_tests
    
    
    run_as_group
    

    
    test from: :suite_100preview_generate_au_ps_using_ips_summary_validation_tests_patient_summary_bundle_validation_tests_bundle_valid
    
    test from: :suite_100preview_generate_au_ps_using_ips_summary_validation_tests_patient_summary_bundle_validation_tests_bundle_valid_ips
    
  end
end
