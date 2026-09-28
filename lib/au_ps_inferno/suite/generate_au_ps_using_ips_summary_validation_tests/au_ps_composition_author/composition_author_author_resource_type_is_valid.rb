# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'

module AUPSTestKit
  # Automatically generated primitive test for Author reference in the AU PS Composition SHALL resolve to a valid resource type (Practitioner, PractitionerRole, Device, Patient, RelatedPerson, Organization).
  class AUPSSuiteGenerateAuPsUsingIpsSummaryValidationTestsAuPsCompositionAuthorAuthorReferenceInTheAuPsCompositionShallResolveToAValidResourceTypePractitionerPractitionerroleDevicePatientRelatedpersonOrganization < BasicTest
    title 'Author reference in the AU PS Composition SHALL resolve to a valid resource type (Practitioner, PractitionerRole, Device, Patient, RelatedPerson, Organization).'
    description 'Author reference in the AU PS Composition SHALL resolve to a valid resource type (Practitioner, PractitionerRole, Device, Patient, RelatedPerson, Organization).'
    id :suite_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_author_author_resource_type_is_valid

    run do
      test_resource_type_is_valid?('author')
    end
  end
end
