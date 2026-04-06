# frozen_string_literal: true

require_relative '../basic_test_contants_module'

module AUPSTestKit
  # Additional Patient (subject) Must Support tests: sub-elements and identifier slices.
  module BasicTestSubjectPatientMsOtherTests
    include BasicTestConstants

    def test_subject_ms_subelements_when_parent_populated
      resource = subject_resource
      skip_if resource.blank?, 'No subject (Patient) resource to validate for Must Support sub-elements'

      validate_populated_sub_elements_when_parent_populated(resource, PATIENT_MS_SUBELEMENT_GROUPS)
    end

    def test_subject_ms_identifier_slices
      resource = subject_resource
      skip_if resource.blank?, 'No subject (Patient) resource to validate for identifier slices'

      validate_ms_identifier_slices_in_resource(resource, PATIENT_MS_IDENTIFIER_SLICES)
    end
  end
end
