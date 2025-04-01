# frozen_string_literal: true

module AUPSTestKit
  class AuPsPatientEntryTest < Inferno::Test
    title 'Server returns AU PS Patient resource that matches the AU PS Patient profile'
    description %(
      This test will validate that the AU PS Patient resource returned from the server matches the AU PS Patient profile.
    )
    id :au_ps_au_ps_patient_entry_test
    
    uses_request :summary_operation

    run do
      initial_bundle = resource
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'Patient' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-patient')
      end
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'Patient' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-patient')
      end

      skip_if existing_resources.empty?, "No existing resources of type 'Patient' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-patient' found."

      existing_resources.each do |r|
        
        assert_valid_resource(resource: r, profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-patient')
        
      end
    end
  end
end
