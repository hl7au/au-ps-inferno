# frozen_string_literal: true



require_relative 'au_ps_composition_recommended_sections/suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_composition_recommended_sections_sections_should_populated'


module AUPSTestKit
  # Automatically generated primitive group for AU PS Composition Recommended Sections
  class AUPSSuite100ballotRetrieveAuPsBundleValidationTestsAuPsCompositionRecommendedSections < Inferno::TestGroup
    title 'AU PS Composition Recommended Sections'
    description 'Verifies that recommended (SHOULD) sections are correctly populated when data is known.'
    id :suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_composition_recommended_sections
    
    optional
    
    
    run_as_group
    

    
    test from: :suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_composition_recommended_sections_sections_should_populated
    
  end
end
