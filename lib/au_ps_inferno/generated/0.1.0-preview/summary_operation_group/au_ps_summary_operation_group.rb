# frozen_string_literal: true


require_relative './summary_operation_support'

require_relative './summary_operation_return_bundle'

require_relative './summary_operation_valid_composition'

require_relative './aups_inferno_ips_problems_section_composition_section_test'

require_relative './aups_inferno_ips_allergiesand_intolerances_section_composition_section_test'

require_relative './aups_inferno_ips_medication_summary_section_composition_section_test'

require_relative './aups_inferno_immunizations_section_composition_section_test'


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
    
    

  end
end
