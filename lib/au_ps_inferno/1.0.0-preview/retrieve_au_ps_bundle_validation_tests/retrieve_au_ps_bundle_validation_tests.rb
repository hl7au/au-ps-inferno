# frozen_string_literal: true


require_relative 'patient_summary_bundle_validation_tests'

require_relative 'au_ps_bundle_conformance_tests'

require_relative 'au_ps_composition_conformance_tests'

require_relative 'au_ps_composition_mandatory_sections'

require_relative 'au_ps_composition_recommended_sections'

require_relative 'au_ps_composition_optional_sections'

require_relative 'au_ps_composition_undefined_sections'

require_relative 'au_ps_composition_subject'

require_relative 'au_ps_composition_author'

require_relative 'au_ps_composition_custodian'

require_relative 'au_ps_composition_attester'


module AUPSTestKit
  # Automatically generated high order group for Retrieve AU PS Bundle validation tests
  class AUPSSuite100previewRetrieveAuPsBundleValidationTests < Inferno::TestGroup
    title 'Retrieve AU PS Bundle validation tests'
    description 'Retrieve document Bundle using Bundle read interaction or other HTTP GET request and verify response is valid AU PS Bundle'
    id :suite_100preview_retrieve_au_ps_bundle_validation_tests
    
    
    run_as_group
    

    
    group from: :suite_100preview_retrieve_au_ps_bundle_validation_tests_patient_summary_bundle_validation_tests
    
    group from: :suite_100preview_retrieve_au_ps_bundle_validation_tests_au_ps_bundle_conformance_tests
    
    group from: :suite_100preview_retrieve_au_ps_bundle_validation_tests_au_ps_composition_conformance_tests
    
    group from: :suite_100preview_retrieve_au_ps_bundle_validation_tests_au_ps_composition_mandatory_sections
    
    group from: :suite_100preview_retrieve_au_ps_bundle_validation_tests_au_ps_composition_recommended_sections
    
    group from: :suite_100preview_retrieve_au_ps_bundle_validation_tests_au_ps_composition_optional_sections
    
    group from: :suite_100preview_retrieve_au_ps_bundle_validation_tests_au_ps_composition_undefined_sections
    
    group from: :suite_100preview_retrieve_au_ps_bundle_validation_tests_au_ps_composition_subject
    
    group from: :suite_100preview_retrieve_au_ps_bundle_validation_tests_au_ps_composition_author
    
    group from: :suite_100preview_retrieve_au_ps_bundle_validation_tests_au_ps_composition_custodian
    
    group from: :suite_100preview_retrieve_au_ps_bundle_validation_tests_au_ps_composition_attester
    
  end
end
