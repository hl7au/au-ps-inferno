# frozen_string_literal: true

require_relative 'au_ps_sections_problems_validation_100preview'

require_relative 'au_ps_sections_allergies_and_intolerances_validation_100preview'

require_relative 'au_ps_sections_medication_summary_validation_100preview'

require_relative 'au_ps_sections_immunizations_validation_100preview'

require_relative 'au_ps_sections_results_validation_100preview'

require_relative 'au_ps_sections_history_of_procedures_validation_100preview'

require_relative 'au_ps_sections_medical_devices_validation_100preview'

require_relative 'au_ps_sections_advance_directives_validation_100preview'

require_relative 'au_ps_sections_alerts_validation_100preview'

require_relative 'au_ps_sections_functional_status_validation_100preview'

require_relative 'au_ps_sections_history_of_past_illness_validation_100preview'

require_relative 'au_ps_sections_history_of_pregnancy_validation_100preview'

require_relative 'au_ps_sections_patient_story_validation_100preview'

require_relative 'au_ps_sections_plan_of_care_validation_100preview'

require_relative 'au_ps_sections_social_history_validation_100preview'

require_relative 'au_ps_sections_vital_signs_validation_100preview'

module AUPSTestKit
  # Automatically generated test group for AU PS Sections Validation
  class AUPSSectionsValidationGroup100preview < Inferno::TestGroup
    title 'AU PS Sections Validation'
    description 'Verify that an AU PS Sections are valid.'
    id :au_ps_sections_validation_group_100preview

    test from: :au_ps_sections_problems_validation_100preview

    test from: :au_ps_sections_allergies_and_intolerances_validation_100preview

    test from: :au_ps_sections_medication_summary_validation_100preview

    test from: :au_ps_sections_immunizations_validation_100preview

    test from: :au_ps_sections_results_validation_100preview

    test from: :au_ps_sections_history_of_procedures_validation_100preview

    test from: :au_ps_sections_medical_devices_validation_100preview

    test from: :au_ps_sections_advance_directives_validation_100preview

    test from: :au_ps_sections_alerts_validation_100preview

    test from: :au_ps_sections_functional_status_validation_100preview

    test from: :au_ps_sections_history_of_past_illness_validation_100preview

    test from: :au_ps_sections_history_of_pregnancy_validation_100preview

    test from: :au_ps_sections_patient_story_validation_100preview

    test from: :au_ps_sections_plan_of_care_validation_100preview

    test from: :au_ps_sections_social_history_validation_100preview

    test from: :au_ps_sections_vital_signs_validation_100preview
  end
end
