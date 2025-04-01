# frozen_string_literal: true

module AUPSTestKit
  class ObservationSocialHistoryTobaccoUseIpsEntryTest < Inferno::Test
    title 'Server returns Observation Social History - Tobacco Use (IPS) resource that matches the Observation Social History - Tobacco Use (IPS) profile'
    description %(
      This test will validate that the Observation Social History - Tobacco Use (IPS) resource returned from the server matches the Observation Social History - Tobacco Use (IPS) profile.
    )
    id :au_ps_observation_social_history_tobacco_use_ips_entry_test
    
    optional
    
    uses_request :summary_operation

    run do
      initial_bundle = resource
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'Observation' && r.meta&.profile&.include?('http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-tobaccouse-uv-ips')
      end
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'Observation' && r.meta&.profile&.include?('http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-tobaccouse-uv-ips')
      end

      skip_if existing_resources.empty?, "No existing resources of type 'Observation' with profile 'http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-tobaccouse-uv-ips' found."

      existing_resources.each do |r|
        
        assert_valid_resource(resource: r, profile_url: 'http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-tobaccouse-uv-ips')
        
      end
    end
  end
end
