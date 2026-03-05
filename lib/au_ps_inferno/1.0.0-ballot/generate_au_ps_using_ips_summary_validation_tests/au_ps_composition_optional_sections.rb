# frozen_string_literal: true



require_relative 'au_ps_composition_optional_sections/suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_optional_sections_sections_may_populated'


module AUPSTestKit
  # Automatically generated primitive group for AU PS Composition Optional Sections
  class AUPSSuite100ballotGenerateAuPsUsingIpsSummaryValidationTestsAuPsCompositionOptionalSections < Inferno::TestGroup
    title 'AU PS Composition Optional Sections'
    description 'Verify the optional sections are correctly populated in the AU PS Composition resource'
    id :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_optional_sections
    
    optional
    
    
    run_as_group
    

    
    test from: :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_optional_sections_sections_may_populated
    
  end
end
