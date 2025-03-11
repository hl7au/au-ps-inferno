# frozen_string_literal: true

module AUPSTestKit
  class AuCoreLocationEntryTest < Inferno::Test
    title 'Server returns AU Core Location resource that matches the AU Core Location profile'
    description %(
      This test will validate that the AU Core Location resource returned from the server matches the AU Core Location profile.
    )
    id :au_ps_au_core_location_entry_test
    
    optional
    
    uses_request :summary_operation

    run do
      initial_bundle = resource
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'Location' && r.meta&.profile&.include?('http://hl7.org.au/fhir/core/StructureDefinition/au-core-location')
      end

      skip_if existing_resources.empty?, "No existing resources of type 'Location' with profile 'http://hl7.org.au/fhir/core/StructureDefinition/au-core-location' found."

      existing_resources.each do |r|
        assert_valid_resource(resource: r, profile_url: 'http://hl7.org.au/fhir/core/StructureDefinition/au-core-location')
      end
    end
  end
end
