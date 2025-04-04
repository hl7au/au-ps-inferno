# frozen_string_literal: true

module AUPSTestKit
  class FlagAlertIpsEntryTest < Inferno::Test
    title 'Server returns Flag - Alert (IPS) resource that matches the Flag - Alert (IPS) profile'
    description %(
      This test will validate that the Flag - Alert (IPS) resource returned from the server matches the Flag - Alert (IPS) profile.
    )
    id :au_ps_flag_alert_ips_entry_test
    
    optional
    
    uses_request :summary_operation

    run do
      initial_bundle = resource
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'Flag' && r.meta&.profile&.include?('http://hl7.org/fhir/uv/ips/StructureDefinition/Flag-alert-uv-ips')
      end
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'Flag' && r.meta&.profile&.include?('http://hl7.org/fhir/uv/ips/StructureDefinition/Flag-alert-uv-ips')
      end

      skip_if existing_resources.empty?, "No existing resources of type 'Flag' with profile 'http://hl7.org/fhir/uv/ips/StructureDefinition/Flag-alert-uv-ips' found."

      existing_resources.each do |r|
        
        assert_valid_resource(resource: r, profile_url: 'http://hl7.org/fhir/uv/ips/StructureDefinition/Flag-alert-uv-ips')
        
      end
    end
  end
end
