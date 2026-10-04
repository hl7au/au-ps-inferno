# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'

module AUPSTestKit
  # Automatically generated primitive test for Subject reference in the AU PS Composition SHALL resolve to a valid resource type (Patient).
  class AUPSSuiteAuPsBundleInstanceAuPsCompositionSubjectSubjectReferenceInTheAuPsCompositionShallResolveToAValidResourceTypePatient < BasicTest
    title 'Subject reference in the AU PS Composition SHALL resolve to a valid resource type (Patient).'
    description 'Subject reference in the AU PS Composition SHALL resolve to a valid resource type (Patient).'
    id :suite_au_ps_bundle_instance_au_ps_composition_subject_subject_resource_type_is_valid

    run do
      test_resource_type_is_valid?('subject')
    end
  end
end
