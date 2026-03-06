# frozen_string_literal: true



require_relative 'au_ps_composition_subject/suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_subject_subject_ms_elements'

require_relative 'au_ps_composition_subject/suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_subject_subject_ms_subelements_populated'

require_relative 'au_ps_composition_subject/suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_subject_subject_ms_identifier_slices'


module AUPSTestKit
  # Automatically generated primitive group for AU PS Composition Subject
  class AUPSSuite100ballotGenerateAuPsUsingIpsSummaryValidationTestsAuPsCompositionSubject < Inferno::TestGroup
    title 'AU PS Composition Subject'
    description 'Verify the referenced subject is a correctly populated AU PS Patient resource.'
    id :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_subject
    
    
    run_as_group
    

    
    test from: :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_subject_subject_ms_elements
    
    test from: :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_subject_subject_ms_subelements_populated
    
    test from: :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_subject_subject_ms_identifier_slices
    
  end
end
