# frozen_string_literal: true

require_relative 'au_ps_composition_attester/suite_retrieve_au_ps_bundle_validation_tests_au_ps_composition_attester_attester_party_ms_elements'

require_relative 'au_ps_composition_attester/suite_retrieve_au_ps_bundle_validation_tests_au_ps_composition_attester_attester_party_ms_subelements'

require_relative 'au_ps_composition_attester/suite_retrieve_au_ps_bundle_validation_tests_au_ps_composition_attester_attester_party_ms_identifier_slices'

module AUPSTestKit
  # Automatically generated primitive group for AU PS Composition Attester
  class AUPSSuiteRetrieveAuPsBundleValidationTestsAuPsCompositionAttester100preview < Inferno::TestGroup
    title 'AU PS Composition Attester'
    description 'Verify the referenced attester.party is a correctly populated AU PS Patient, RelatedPerson, Practitioner, PractitionerRole, or Organization resource.'
    id :suite_retrieve_au_ps_bundle_validation_tests_au_ps_composition_attester_100preview

    optional

    run_as_group

    test from: :suite_retrieve_au_ps_bundle_validation_tests_au_ps_composition_attester_attester_party_ms_elements_100preview

    test from: :suite_retrieve_au_ps_bundle_validation_tests_au_ps_composition_attester_attester_party_ms_subelements_100preview

    test from: :suite_retrieve_au_ps_bundle_validation_tests_au_ps_composition_attester_attester_party_ms_identifier_slices_100preview
  end
end
