# frozen_string_literal: true


require_relative './summary_operation_support'

require_relative './summary_operation_return_bundle'

require_relative './summary_operation_valid_composition'

require_relative './aups_inferno_ips_problems_section_composition_section_test'

require_relative './aups_inferno_ips_allergiesand_intolerances_section_composition_section_test'

require_relative './aups_inferno_ips_medication_summary_section_composition_section_test'

require_relative './aups_inferno_immunizations_section_composition_section_test'

require_relative './summary_operation_support'

require_relative './summary_operation_return_bundle'

require_relative './summary_operation_valid_composition'

require_relative './aups_inferno_ips_problems_section_composition_section_test'

require_relative './aups_inferno_ips_allergiesand_intolerances_section_composition_section_test'

require_relative './aups_inferno_ips_medication_summary_section_composition_section_test'

require_relative './aups_inferno_ips_immunizations_section_composition_section_test'

require_relative './aups_inferno_ips_results_section_composition_section_test'

require_relative './aups_inferno_ips_historyof_procedures_section_composition_section_test'

require_relative './aups_inferno_ips_medical_devices_section_composition_section_test'

require_relative './aups_inferno_ips_advance_directives_section_composition_section_test'

require_relative './aups_inferno_ips_alerts_section_composition_section_test'

require_relative './aups_inferno_ips_functional_status_composition_section_test'

require_relative './aups_inferno_ips_historyof_past_illness_section_composition_section_test'

require_relative './aups_inferno_ips_historyof_pregnancy_section_composition_section_test'

require_relative './aups_inferno_ips_patient_story_section_composition_section_test'

require_relative './aups_inferno_ips_planof_care_section_composition_section_test'

require_relative './aups_inferno_ips_social_history_section_composition_section_test'

require_relative './aups_inferno_ips_vital_signs_section_composition_section_test'


module AUPSTestKit
  class SummaryOperationGroup < Inferno::TestGroup
    title '$summary Operation Tests'
    description 'Verify support for the $summary operation as as described in the AU PS Guidance'
    id :au_ps_summary_operation
    run_as_group

    
    
    test from: :au_ps_summary_operation_support
    
    
    
    test from: :au_ps_summary_operation_return_bundle
    
    
    
    test from: :au_ps_summary_operation_valid_composition
    
    
    
    test from: :au_ps_ips_problems_section_composition_section_test
    
    
    
    test from: :au_ps_ips_allergies_and_intolerances_section_composition_section_test
    
    
    
    test from: :au_ps_ips_medication_summary_section_composition_section_test
    
    
    
    test from: :au_ps_immunizations_section_composition_section_test
    
    
    
    test from: :au_ps_summary_operation_support
    
    
    
    test from: :au_ps_summary_operation_return_bundle
    
    
    
    test from: :au_ps_summary_operation_valid_composition
    
    
    
    test from: :au_ps_ips_problems_section_composition_section_test
    
    
    
    test from: :au_ps_ips_allergies_and_intolerances_section_composition_section_test
    
    
    
    test from: :au_ps_ips_medication_summary_section_composition_section_test
    
    
    
    test from: :au_ps_ips_immunizations_section_composition_section_test
    
    
    
    test from: :au_ps_ips_results_section_composition_section_test
    
    
    
    test from: :au_ps_ips_history_of_procedures_section_composition_section_test
    
    
    
    test from: :au_ps_ips_medical_devices_section_composition_section_test
    
    
    
    test from: :au_ps_ips_advance_directives_section_composition_section_test
    
    
    
    test from: :au_ps_ips_alerts_section_composition_section_test
    
    
    
    test from: :au_ps_ips_functional_status_composition_section_test
    
    
    
    test from: :au_ps_ips_history_of_past_illness_section_composition_section_test
    
    
    
    test from: :au_ps_ips_history_of_pregnancy_section_composition_section_test
    
    
    
    test from: :au_ps_ips_patient_story_section_composition_section_test
    
    
    
    test from: :au_ps_ips_plan_of_care_section_composition_section_test
    
    
    
    test from: :au_ps_ips_social_history_section_composition_section_test
    
    
    
    test from: :au_ps_ips_vital_signs_section_composition_section_test
    
    

  end
end
