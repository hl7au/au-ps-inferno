# frozen_string_literal: true



require_relative 'patient_summary_bundle_validation_tests/suite_100preview_au_ps_bundle_instance_patient_summary_bundle_validation_tests_bundle_valid'

require_relative 'patient_summary_bundle_validation_tests/suite_100preview_au_ps_bundle_instance_patient_summary_bundle_validation_tests_bundle_valid_ips'


module AUPSTestKit
  # Automatically generated primitive group for Patient Summary Bundle Validation Tests
  class AUPSSuite100previewAuPsBundleInstancePatientSummaryBundleValidationTests < Inferno::TestGroup
    title 'Patient Summary Bundle Validation Tests'
    description 'Validates that the Bundle resource conforms to the AU Patient Summary profiles.'
    id :suite_100preview_au_ps_bundle_instance_patient_summary_bundle_validation_tests
    
    
    run_as_group
    

    
    test from: :suite_100preview_au_ps_bundle_instance_patient_summary_bundle_validation_tests_bundle_valid
    
    test from: :suite_100preview_au_ps_bundle_instance_patient_summary_bundle_validation_tests_bundle_valid_ips
    
  end
end
