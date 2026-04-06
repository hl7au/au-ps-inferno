# frozen_string_literal: true

require_relative '../basic_test_contants_module'

module AUPSTestKit
  # Additional Patient (subject) Must Support tests: sub-elements and identifier slices.
  module BasicTestSubjectPatientMsOtherTests
    include BasicTestConstants

    def test_subject_ms_identifier_slices
      resource_is_poluated = raw_resource_type_is_valid('subject')
      skip_if !resource_is_poluated[:valid?], resource_is_poluated[:msg]

      validate_ms_identifier_slices_in_resource(subject_resource, PATIENT_MS_IDENTIFIER_SLICES)
    end
  end
end
