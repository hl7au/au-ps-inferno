# frozen_string_literal: true


require_relative './summary_operation_support'

require_relative './summary_operation_return_bundle'

require_relative './summary_operation_valid_composition'

require_relative './aups_inferno_patient_summary_problems_section_composition_section_test'

require_relative './aups_inferno_patient_summary_allergiesand_intolerances_section_composition_section_test'

require_relative './aups_inferno_patient_summary_medication_summary_section_composition_section_test'

require_relative './aups_inferno_patient_summary_immunizations_section_composition_section_test'

require_relative './aups_inferno_patient_summary_results_section_composition_section_test'

require_relative './aups_inferno_patient_summary_historyof_procedures_section_composition_section_test'

require_relative './aups_inferno_patient_summary_medical_devices_section_composition_section_test'

require_relative './aups_inferno_patient_summary_advance_directives_section_composition_section_test'

require_relative './aups_inferno_patient_summary_alerts_section_composition_section_test'

require_relative './aups_inferno_patient_summary_functional_status_section_composition_section_test'

require_relative './aups_inferno_patient_summary_historyof_past_illness_section_composition_section_test'

require_relative './aups_inferno_patient_summary_historyof_pregnancy_section_composition_section_test'

require_relative './aups_inferno_patient_summary_patient_story_section_composition_section_test'

require_relative './aups_inferno_patient_summary_planof_care_section_composition_section_test'

require_relative './aups_inferno_patient_summary_social_history_section_composition_section_test'

require_relative './aups_inferno_patient_summary_vital_signs_section_composition_section_test'


module AUPSTestKit
  class SummaryOperationGroup < Inferno::TestGroup
    title '$summary Operation: Validate Bundle'
    description 'Verify that the $summary operation returns a valid AU PS Bundle, or validate a provided Bundle.'
    id :au_ps_summary_operation
    run_as_group

    
    
    # test from: :au_ps_summary_operation_support
    
    
    
    test from: :au_ps_summary_operation_return_bundle
    
    
    #
    # test from: :au_ps_summary_operation_valid_composition
    #
    #
    #
    # test from: :au_ps_patient_summary_problems_section_composition_section_test
    #
    #
    #
    # test from: :au_ps_patient_summary_allergies_and_intolerances_section_composition_section_test
    #
    #
    #
    # test from: :au_ps_patient_summary_medication_summary_section_composition_section_test
    #
    #
    #
    # test from: :au_ps_patient_summary_immunizations_section_composition_section_test
    #
    #
    #
    # test from: :au_ps_patient_summary_results_section_composition_section_test
    #
    #
    #
    # test from: :au_ps_patient_summary_history_of_procedures_section_composition_section_test
    #
    #
    #
    # test from: :au_ps_patient_summary_medical_devices_section_composition_section_test
    #
    #
    #
    # test from: :au_ps_patient_summary_advance_directives_section_composition_section_test
    #
    #
    #
    # test from: :au_ps_patient_summary_alerts_section_composition_section_test
    #
    #
    #
    # test from: :au_ps_patient_summary_functional_status_section_composition_section_test
    #
    #
    #
    # test from: :au_ps_patient_summary_history_of_past_illness_section_composition_section_test
    #
    #
    #
    # test from: :au_ps_patient_summary_history_of_pregnancy_section_composition_section_test
    #
    #
    #
    # test from: :au_ps_patient_summary_patient_story_section_composition_section_test
    #
    #
    #
    # test from: :au_ps_patient_summary_plan_of_care_section_composition_section_test
    #
    #
    #
    # test from: :au_ps_patient_summary_social_history_section_composition_section_test
    #
    #
    #
    # test from: :au_ps_patient_summary_vital_signs_section_composition_section_test
    #
    

  end
end
