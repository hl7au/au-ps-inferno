# frozen_string_literal: true


require_relative './au_ps_patient_entry_test'

require_relative './au_ps_allergyintolerance_entry_test'

require_relative './au_ps_condition_entry_test'

require_relative './device_entry_test'

require_relative './deviceusestatement_ips_entry_test'

require_relative './diagnosticreport_ips_entry_test'

require_relative './imagingstudy_ips_entry_test'

require_relative './au_ps_immunization_entry_test'

require_relative './au_ps_medication_entry_test'

require_relative './au_ps_medicationrequest_entry_test'

require_relative './au_ps_medicationstatement_entry_test'

require_relative './au_ps_practitioner_entry_test'

require_relative './au_ps_practitionerrole_entry_test'

require_relative './au_ps_procedure_entry_test'

require_relative './au_ps_organization_entry_test'

require_relative './observation_entry_test'

require_relative './specimen_ips_entry_test'

require_relative './flag_alert_ips_entry_test'

require_relative './clinicalimpression_entry_test'

require_relative './careplan_entry_test'

require_relative './consent_entry_test'

require_relative './documentreference_entry_test'

require_relative './au_ps_encounter_entry_test'

require_relative './au_core_location_entry_test'

require_relative './au_ps_relatedperson_entry_test'

require_relative './careteam_entry_test'

require_relative './immunizationrecommendation_entry_test'


module AUPSTestKit
  class EntriesGroup < Inferno::TestGroup
    title '$summary Entries Tests'
    description 'A set of tests to check entries from $summary for read action and validate them according to profile specified in the AU PS Implementation Guide'
    id :au_ps_entries
    run_as_group

    
    
    test from: :au_ps_au_ps_patient_entry_test
    
    
    
    test from: :au_ps_au_ps_allergyintolerance_entry_test
    
    
    
    test from: :au_ps_au_ps_condition_entry_test
    
    
    
    test from: :au_ps_device_entry_test
    
    
    
    test from: :au_ps_deviceusestatement_ips_entry_test
    
    
    
    test from: :au_ps_diagnosticreport_ips_entry_test
    
    
    
    test from: :au_ps_imagingstudy_ips_entry_test
    
    
    
    test from: :au_ps_au_ps_immunization_entry_test
    
    
    
    test from: :au_ps_au_ps_medication_entry_test
    
    
    
    test from: :au_ps_au_ps_medicationrequest_entry_test
    
    
    
    test from: :au_ps_au_ps_medicationstatement_entry_test
    
    
    
    test from: :au_ps_au_ps_practitioner_entry_test
    
    
    
    test from: :au_ps_au_ps_practitionerrole_entry_test
    
    
    
    test from: :au_ps_au_ps_procedure_entry_test
    
    
    
    test from: :au_ps_au_ps_organization_entry_test
    
    
    
    test from: :au_ps_observation_entry_test
    
    
    
    test from: :au_ps_specimen_ips_entry_test
    
    
    
    test from: :au_ps_flag_alert_ips_entry_test
    
    
    
    test from: :au_ps_clinicalimpression_entry_test
    
    
    
    test from: :au_ps_careplan_entry_test
    
    
    
    test from: :au_ps_consent_entry_test
    
    
    
    test from: :au_ps_documentreference_entry_test
    
    
    
    test from: :au_ps_au_ps_encounter_entry_test
    
    
    
    test from: :au_ps_au_core_location_entry_test
    
    
    
    test from: :au_ps_au_ps_relatedperson_entry_test
    
    
    
    test from: :au_ps_careteam_entry_test
    
    
    
    test from: :au_ps_immunizationrecommendation_entry_test
    
    

  end
end
