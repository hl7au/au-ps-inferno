# frozen_string_literal: true



require_relative 'au_ps_composition_mandatory_sections/suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_mandatory_sections_sections_shall_populated'

require_relative 'au_ps_composition_mandatory_sections/suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_mandatory_sections_sections_entry_profiles'


module AUPSTestKit
  # Automatically generated primitive group for AU PS Composition Mandatory Sections
  class AUPSSuite100ballotGenerateAuPsUsingIpsSummaryValidationTestsAuPsCompositionMandatorySections < Inferno::TestGroup
    title 'AU PS Composition Mandatory Sections'
    description 'Verifies that mandatory sections are present and section.entry references conform to the required profiles.'
    id :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_mandatory_sections
    
    
    run_as_group
    

    
    test from: :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_mandatory_sections_sections_shall_populated
    
    test from: :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_mandatory_sections_sections_entry_profiles
    
  end
end
