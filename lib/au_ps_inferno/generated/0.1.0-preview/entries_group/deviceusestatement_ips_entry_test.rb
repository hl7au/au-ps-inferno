# frozen_string_literal: true

module AUPSTestKit
  class DeviceusestatementIpsEntryTest < Inferno::Test
    title 'Server returns DeviceUseStatement (IPS) resource that matches the DeviceUseStatement (IPS) profile'
    description %(
      This test will validate that the DeviceUseStatement (IPS) resource returned from the server matches the DeviceUseStatement (IPS) profile.
    )
    id :au_ps_deviceusestatement_ips_entry_test
    
    optional
    
    uses_request :summary_operation

    run do
      initial_bundle = resource
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'DeviceUseStatement' && r.meta&.profile&.include?('http://hl7.org/fhir/uv/ips/StructureDefinition/DeviceUseStatement-uv-ips')
      end

      skip_if existing_resources.empty?, "No existing resources of type 'DeviceUseStatement' with profile 'http://hl7.org/fhir/uv/ips/StructureDefinition/DeviceUseStatement-uv-ips' found."

      existing_resources.each do |r|
        assert_valid_resource(resource: r, profile_url: 'http://hl7.org/fhir/uv/ips/StructureDefinition/DeviceUseStatement-uv-ips')
      end
    end
  end
end
