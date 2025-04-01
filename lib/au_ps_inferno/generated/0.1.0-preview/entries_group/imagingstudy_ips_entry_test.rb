# frozen_string_literal: true

module AUPSTestKit
  class ImagingstudyIpsEntryTest < Inferno::Test
    title 'Server returns ImagingStudy (IPS) resource that matches the ImagingStudy (IPS) profile'
    description %(
      This test will validate that the ImagingStudy (IPS) resource returned from the server matches the ImagingStudy (IPS) profile.
    )
    id :au_ps_imagingstudy_ips_entry_test
    
    optional
    
    uses_request :summary_operation

    run do
      initial_bundle = resource
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'ImagingStudy' && r.meta&.profile&.include?('http://hl7.org/fhir/uv/ips/StructureDefinition/ImagingStudy-uv-ips')
      end
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'ImagingStudy' && r.meta&.profile&.include?('http://hl7.org/fhir/uv/ips/StructureDefinition/ImagingStudy-uv-ips')
      end

      skip_if existing_resources.empty?, "No existing resources of type 'ImagingStudy' with profile 'http://hl7.org/fhir/uv/ips/StructureDefinition/ImagingStudy-uv-ips' found."

      existing_resources.each do |r|
        
        assert_valid_resource(resource: r, profile_url: 'http://hl7.org/fhir/uv/ips/StructureDefinition/ImagingStudy-uv-ips')
        
      end
    end
  end
end
