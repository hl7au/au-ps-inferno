# frozen_string_literal: true

require_relative './au_ps_sections_problems_validation'
require_relative './au_ps_sections_allergies_validation'
require_relative './au_ps_sections_medications_validation'
require_relative './au_ps_sections_immunizations_validation'
require_relative './au_ps_sections_results_validation'
require_relative './au_ps_sections_procedures_validation'
require_relative './au_ps_sections_medical_devices_validation'
require_relative './au_ps_sections_advance_directives_validation'
require_relative './au_ps_sections_alerts_validation'
require_relative './au_ps_sections_functional_status_validation'
require_relative './au_ps_sections_past_problems_validation'
require_relative './au_ps_sections_pregnancy_validation'
require_relative './au_ps_sections_patient_story_validation'
require_relative './au_ps_sections_plan_of_care_validation'
require_relative './au_ps_sections_social_history_validation'
require_relative './au_ps_sections_vital_signs_validation'
require_relative '../utils/constants'

module AUPSTestKit
  # Verify that the AU PS Sections are valid
  class AUPSSectionsValidationGroup < Inferno::TestGroup
    extend Constants

    title 'AU PS Sections Validation'
    description 'Verify that an AU PS Sections are valid.'
    id :au_ps_sections_validation_group

    test from: :au_ps_sections_problems_validation
    test from: :au_ps_sections_allergies_validation
    test from: :au_ps_sections_medications_validation
    test from: :au_ps_sections_immunizations_validation
    test from: :au_ps_sections_results_validation
    test from: :au_ps_sections_procedures_validation
    test from: :au_ps_sections_medical_devices_validation
    test from: :au_ps_sections_advance_directives_validation
    test from: :au_ps_sections_alerts_validation
    test from: :au_ps_sections_functional_status_validation
    test from: :au_ps_sections_past_problems_validation
    test from: :au_ps_sections_pregnancy_validation
    test from: :au_ps_sections_patient_story_validation
    test from: :au_ps_sections_plan_of_care_validation
    test from: :au_ps_sections_social_history_validation
    test from: :au_ps_sections_vital_signs_validation
  end
end
