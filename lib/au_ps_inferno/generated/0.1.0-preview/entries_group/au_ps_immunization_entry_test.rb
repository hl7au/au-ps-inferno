# frozen_string_literal: true

module AUPSTestKit
  class AuPsImmunizationEntryTest < Inferno::Test
    title 'Server returns AU PS Immunization resource that matches the AU PS Immunization profile'
    description %(
      This test will validate that the AU PS Immunization resource returned from the server matches the AU PS Immunization profile.
    )
    id :au_ps_au_ps_immunization_entry_test
    
    optional
    
    uses_request :summary_operation

    run do
      initial_bundle = resource
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'Immunization' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-immunization')
      end

      skip_if existing_resources.empty?, "No existing resources of type 'Immunization' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-immunization' found."

      existing_resources.each do |r|
        assert_valid_resource(resource: r, profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-immunization')
      end
    end
  end
end
