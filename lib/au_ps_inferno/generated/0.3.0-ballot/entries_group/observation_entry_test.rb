# frozen_string_literal: true

module AUPSTestKit
  class ObservationEntryTest < Inferno::Test
    title 'Server returns Observation resource that matches the Observation profile'
    description %(
      This test will validate that the Observation resource returned from the server matches the Observation profile.
    )
    id :au_ps_observation_entry_test
    
    optional
    
    uses_request :summary_operation

    run do
      initial_bundle = resource
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'Observation' && r.meta&.profile&.include?('http://hl7.org/fhir/StructureDefinition/Observation')
      end
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'Observation' && r.meta&.profile&.include?('http://hl7.org/fhir/StructureDefinition/Observation')
      end

      skip_if existing_resources.empty?, "No existing resources of type 'Observation' with profile 'http://hl7.org/fhir/StructureDefinition/Observation' found."

      existing_resources.each do |r|
        
        assert_valid_resource(resource: r, profile_url: 'http://hl7.org/fhir/StructureDefinition/Observation')
        
      end
    end
  end
end
