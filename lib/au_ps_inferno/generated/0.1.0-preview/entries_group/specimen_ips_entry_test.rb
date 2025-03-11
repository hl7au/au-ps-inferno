# frozen_string_literal: true

module AUPSTestKit
  class SpecimenIpsEntryTest < Inferno::Test
    title 'Server returns Specimen (IPS) resource that matches the Specimen (IPS) profile'
    description %(
      This test will validate that the Specimen (IPS) resource returned from the server matches the Specimen (IPS) profile.
    )
    id :au_ps_specimen_ips_entry_test
    
    optional
    
    uses_request :summary_operation

    run do
      initial_bundle = resource
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'Specimen' && r.meta&.profile&.include?('http://hl7.org/fhir/uv/ips/StructureDefinition/Specimen-uv-ips')
      end

      skip_if existing_resources.empty?, "No existing resources of type 'Specimen' with profile 'http://hl7.org/fhir/uv/ips/StructureDefinition/Specimen-uv-ips' found."

      existing_resources.each do |r|
        assert_valid_resource(resource: r, profile_url: 'http://hl7.org/fhir/uv/ips/StructureDefinition/Specimen-uv-ips')
      end
    end
  end
end
