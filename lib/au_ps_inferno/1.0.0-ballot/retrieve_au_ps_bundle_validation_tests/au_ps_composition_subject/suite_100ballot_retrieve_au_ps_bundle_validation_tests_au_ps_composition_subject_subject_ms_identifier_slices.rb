# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'


module AUPSTestKit
  # Automatically generated primitive test for Must Support identifier slices SHALL be populated if a value is known
  class AUPSSuite100ballotRetrieveAuPsBundleValidationTestsAuPsCompositionSubjectMustSupportIdentifierSlicesShallBePopulatedIfAValueIsKnown < BasicTest
    title 'Must Support identifier slices SHALL be populated if a value is known'
    description 'Must Support identifier slices SHALL be populated if a value is known (i.e. ihi, dva, medicare).'
    id :suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_composition_subject_subject_ms_identifier_slices
    
    
    run do
      
      test_subject_ms_identifier_slices
      
    end
    
  end
end
