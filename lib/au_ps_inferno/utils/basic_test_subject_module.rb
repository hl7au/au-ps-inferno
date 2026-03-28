# frozen_string_literal: true

require_relative 'basic_test_subject_resource'
require_relative 'basic_test_subject_patient_ms_elements'
require_relative 'basic_test_subject_patient_ms_other_tests'

module AUPSTestKit
  # Composes Composition subject (Patient) Must Support test helpers for BasicTest.
  module BasicTestSubjectModule
    include BasicTestSubjectResource
    include BasicTestSubjectPatientMsElements
    include BasicTestSubjectPatientMsOtherTests
  end
end
