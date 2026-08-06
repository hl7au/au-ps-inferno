# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'

module AUPSTestKit
  # Warns against using emptyReason=nilknown instead of an explicit negation entry
  class AUPSSuiteRetrieveAuPsBundleValidationTestsAuPsCompositionMandatorySectionsNilknownWarning < BasicTest
    title 'AU PS Composition Mandatory Sections do not rely on emptyReason=nilknown'
    description 'Warns when a mandatory section (Problems, Allergies, Medications) uses ' \
                 'Composition.section.emptyReason = nilknown instead of an explicit negation code on the ' \
                 "section's entry resource (e.g. AllergyIntolerance.code = 716186003 |No known allergy|). " \
                 'AU PS prefers the explicit-entry pattern used by FHIR, IPS and AU Core over emptyReason ' \
                 '- this is a warning, not a failure.'
    id :suite_retrieve_au_ps_bundle_validation_tests_au_ps_composition_mandatory_sections_nilknown_warning

    run do
      warn_on_nilknown_empty_reason(MANDATORY_SECTIONS_CODES)
    end
  end
end
