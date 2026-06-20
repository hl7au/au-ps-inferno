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
  # Automatically generated high order group for Generate AU PS using IPS $summary validation tests
  class AUPSSuite100previewGenerateAuPsUsingIpsSummaryValidationTests < Inferno::TestGroup
    title 'Generate AU PS using IPS $summary validation tests'
    description 'Generate AU Patient Summary using IPS $summary operation and verify response is valid AU PS Bundle'
    id :suite_100preview_generate_au_ps_using_ips_summary_validation_tests
    
    
    run_as_group
    

    
    group from: :suite_100preview_generate_au_ps_using_ips_summary_validation_tests_patient_summary_bundle_validation_tests
    
    group from: :suite_100preview_generate_au_ps_using_ips_summary_validation_tests_au_ps_bundle_conformance_tests
    
    group from: :suite_100preview_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_conformance_tests
    
    group from: :suite_100preview_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_mandatory_sections
    
    group from: :suite_100preview_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_recommended_sections
    
    group from: :suite_100preview_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_optional_sections
    
    group from: :suite_100preview_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_undefined_sections
    
    group from: :suite_100preview_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_subject
    
    group from: :suite_100preview_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_author
    
    group from: :suite_100preview_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_custodian
    
    group from: :suite_100preview_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_attester
    
  end
end
