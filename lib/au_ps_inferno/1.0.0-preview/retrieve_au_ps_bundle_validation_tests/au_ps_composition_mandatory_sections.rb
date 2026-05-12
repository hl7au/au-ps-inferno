# frozen_string_literal: true



require_relative 'au_ps_composition_mandatory_sections/suite_100preview_retrieve_au_ps_bundle_validation_tests_au_ps_composition_mandatory_sections_sections_shall_populated'

require_relative 'au_ps_composition_mandatory_sections/suite_100preview_retrieve_au_ps_bundle_validation_tests_au_ps_composition_mandatory_sections_mandatory_sections_entry_profiles'


module AUPSTestKit
  # Automatically generated primitive group for AU PS Composition Mandatory Sections
  class AUPSSuite100previewRetrieveAuPsBundleValidationTestsAuPsCompositionMandatorySections < Inferno::TestGroup
    title 'AU PS Composition Mandatory Sections'
    description 'Verify the mandatory sections are correctly populated in the AU PS Composition resource'
    id :suite_100preview_retrieve_au_ps_bundle_validation_tests_au_ps_composition_mandatory_sections
    
    
    run_as_group
    

    
    test from: :suite_100preview_retrieve_au_ps_bundle_validation_tests_au_ps_composition_mandatory_sections_sections_shall_populated
    
    test from: :suite_100preview_retrieve_au_ps_bundle_validation_tests_au_ps_composition_mandatory_sections_mandatory_sections_entry_profiles
    
  end
end
