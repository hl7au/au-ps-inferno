# frozen_string_literal: true

module AUPSTestKit
  class AuPsMedicationrequestEntryTest < Inferno::Test
    title 'Server returns AU PS MedicationRequest resource that matches the AU PS MedicationRequest profile'
    description %(
      This test will validate that the AU PS MedicationRequest resource returned from the server matches the AU PS MedicationRequest profile.
    )
    id :au_ps_au_ps_medicationrequest_entry_test
    
    optional
    
    uses_request :summary_operation

    run do
      initial_bundle = resource
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'MedicationRequest' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationrequest')
      end
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'MedicationRequest' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationrequest')
      end

      skip_if existing_resources.empty?, "No existing resources of type 'MedicationRequest' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationrequest' found."

      existing_resources.each do |r|
        
        assert_valid_resource(resource: r, profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationrequest')
        
      end
    end
  end
end
