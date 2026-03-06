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


module AUPSTestKit
  # Automatically generated high order group for Generate AU PS using IPS $summary validation tests
  class AUPSSuite100ballotGenerateAuPsUsingIpsSummaryValidationTests < Inferno::TestGroup
    title 'Generate AU PS using IPS $summary validation tests'
    description 'Generate AU Patient Summary using IPS $summary operation and verify response is valid AU PS Bundle'
    id :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests
    
    
    run_as_group
    

    
    group from: :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_bundle_validation
    
    group from: :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_bundle_must_support_conformance
    
    group from: :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_must_support_conformance
    
    group from: :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_mandatory_sections
    
    group from: :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_recommended_sections
    
    group from: :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_optional_sections
    
    group from: :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_undefined_sections
    
    group from: :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_subject
    
    group from: :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_author
    
  end
end
