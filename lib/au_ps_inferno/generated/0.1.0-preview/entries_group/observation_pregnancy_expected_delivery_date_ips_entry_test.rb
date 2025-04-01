# frozen_string_literal: true

module AUPSTestKit
  class ObservationPregnancyExpectedDeliveryDateIpsEntryTest < Inferno::Test
    title 'Server returns Observation Pregnancy - Expected Delivery Date (IPS) resource that matches the Observation Pregnancy - Expected Delivery Date (IPS) profile'
    description %(
      This test will validate that the Observation Pregnancy - Expected Delivery Date (IPS) resource returned from the server matches the Observation Pregnancy - Expected Delivery Date (IPS) profile.
    )
    id :au_ps_observation_pregnancy_expected_delivery_date_ips_entry_test
    
    optional
    
    uses_request :summary_operation

    run do
      initial_bundle = resource
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'Observation' && r.meta&.profile&.include?('http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-pregnancy-edd-uv-ips')
      end
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'Observation' && r.meta&.profile&.include?('http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-pregnancy-edd-uv-ips')
      end

      skip_if existing_resources.empty?, "No existing resources of type 'Observation' with profile 'http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-pregnancy-edd-uv-ips' found."

      existing_resources.each do |r|
        
        assert_valid_resource(resource: r, profile_url: 'http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-pregnancy-edd-uv-ips')
        
      end
    end
  end
end
