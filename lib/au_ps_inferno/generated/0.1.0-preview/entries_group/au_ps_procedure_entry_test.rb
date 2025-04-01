# frozen_string_literal: true

module AUPSTestKit
  class AuPsProcedureEntryTest < Inferno::Test
    title 'Server returns AU PS Procedure resource that matches the AU PS Procedure profile'
    description %(
      This test will validate that the AU PS Procedure resource returned from the server matches the AU PS Procedure profile.
    )
    id :au_ps_au_ps_procedure_entry_test
    
    optional
    
    uses_request :summary_operation

    run do
      initial_bundle = resource
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'Procedure' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-procedure')
      end
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'Procedure' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-procedure')
      end

      skip_if existing_resources.empty?, "No existing resources of type 'Procedure' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-procedure' found."

      existing_resources.each do |r|
        
        assert_valid_resource(resource: r, profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-procedure')
        
      end
    end
  end
end
