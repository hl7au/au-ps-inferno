# frozen_string_literal: true



require_relative 'au_ps_composition_author/suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_author_author_ms_elements'

require_relative 'au_ps_composition_author/suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_author_author_ms_subelements'


module AUPSTestKit
  # Automatically generated primitive group for AU PS Composition Author
  class AUPSSuite100ballotGenerateAuPsUsingIpsSummaryValidationTestsAuPsCompositionAuthor < Inferno::TestGroup
    title 'AU PS Composition Author'
    description 'Verify the referenced author is a correctly populated AU PS Practitioner, AU PS PractitionerRole, AU PS Patient, AU PS RelatedPerson, AU PS Organization profiles or Device resource.'
    id :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_author
    
    optional
    
    
    run_as_group
    

    
    test from: :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_author_author_ms_elements
    
    test from: :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_author_author_ms_subelements
    
  end
end
