# frozen_string_literal: true


require_relative 'au_ps_bundle_validation'

require_relative 'au_ps_bundle_must_support_conformance'

require_relative 'au_ps_composition_must_support_conformance'

require_relative 'au_ps_composition_mandatory_sections'

require_relative 'au_ps_composition_recommended_sections'

require_relative 'au_ps_composition_optional_sections'

require_relative 'au_ps_composition_undefined_sections'

require_relative 'au_ps_composition_subject'

require_relative 'au_ps_composition_author'

require_relative 'au_ps_composition_custodian'


module AUPSTestKit
  # Automatically generated high order group for Retrieve AU PS Bundle validation tests
  class AUPSSuite100ballotRetrieveAuPsBundleValidationTests < Inferno::TestGroup
    title 'Retrieve AU PS Bundle validation tests'
    description 'Retrieve document Bundle using Bundle read interaction or other HTTP GET request and verify response is valid AU PS Bundle'
    id :suite_100ballot_retrieve_au_ps_bundle_validation_tests
    
    
    run_as_group
    

    
    group from: :suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_bundle_validation
    
    group from: :suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_bundle_must_support_conformance
    
    group from: :suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_composition_must_support_conformance
    
    group from: :suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_composition_mandatory_sections
    
    group from: :suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_composition_recommended_sections
    
    group from: :suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_composition_optional_sections
    
    group from: :suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_composition_undefined_sections
    
    group from: :suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_composition_subject
    
    group from: :suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_composition_author
    
    group from: :suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_composition_custodian
    
  end
end
