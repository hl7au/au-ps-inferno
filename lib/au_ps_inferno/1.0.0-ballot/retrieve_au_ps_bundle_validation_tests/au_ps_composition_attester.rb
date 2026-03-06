# frozen_string_literal: true



require_relative 'au_ps_composition_attester/suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_composition_attester_attester_party_ms_elements'

require_relative 'au_ps_composition_attester/suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_composition_attester_attester_party_ms_subelements'

require_relative 'au_ps_composition_attester/suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_composition_attester_attester_party_ms_identifier_slices'


module AUPSTestKit
  # Automatically generated primitive group for AU PS Composition Attester
  class AUPSSuite100ballotRetrieveAuPsBundleValidationTestsAuPsCompositionAttester < Inferno::TestGroup
    title 'AU PS Composition Attester'
    description 'Verify the referenced attester.party is a correctly populated AU PS Patient, RelatedPerson, Practitioner, PractitionerRole, or Organization resource.'
    id :suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_composition_attester
    
    
    run_as_group
    

    
    test from: :suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_composition_attester_attester_party_ms_elements
    
    test from: :suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_composition_attester_attester_party_ms_subelements
    
    test from: :suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_composition_attester_attester_party_ms_identifier_slices
    
  end
end
