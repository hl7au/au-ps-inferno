# frozen_string_literal: true

module AUPSTestKit
  class AuPsMedicationstatementEntryTest < Inferno::Test
    title 'Server returns AU PS MedicationStatement resource that matches the AU PS MedicationStatement profile'
    description %(
      This test will validate that the AU PS MedicationStatement resource returned from the server matches the AU PS MedicationStatement profile.
    )
    id :au_ps_au_ps_medicationstatement_entry_test
    
    optional
    
    uses_request :summary_operation

    run do
      initial_bundle = resource
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'MedicationStatement' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement')
      end
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'MedicationStatement' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement')
      end

      skip_if existing_resources.empty?, "No existing resources of type 'MedicationStatement' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement' found."

      existing_resources.each do |r|
        
        assert_valid_resource(resource: r, profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement')
        
      end
    end
  end
end
