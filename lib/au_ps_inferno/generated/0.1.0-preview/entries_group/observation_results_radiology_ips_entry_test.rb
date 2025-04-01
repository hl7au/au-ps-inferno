# frozen_string_literal: true

module AUPSTestKit
  class ObservationResultsRadiologyIpsEntryTest < Inferno::Test
    title 'Server returns Observation Results - Radiology (IPS) resource that matches the Observation Results - Radiology (IPS) profile'
    description %(
      This test will validate that the Observation Results - Radiology (IPS) resource returned from the server matches the Observation Results - Radiology (IPS) profile.
    )
    id :au_ps_observation_results_radiology_ips_entry_test
    
    optional
    
    uses_request :summary_operation

    run do
      initial_bundle = resource
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'Observation' && r.meta&.profile&.include?('http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-results-radiology-uv-ips')
      end
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'Observation' && r.meta&.profile&.include?('http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-results-radiology-uv-ips')
      end

      skip_if existing_resources.empty?, "No existing resources of type 'Observation' with profile 'http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-results-radiology-uv-ips' found."

      existing_resources.each do |r|
        
        assert_valid_resource(resource: r, profile_url: 'http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-results-radiology-uv-ips')
        
      end
    end
  end
end
