# frozen_string_literal: true

module AUPSTestKit
  class AuPsOrganizationEntryTest < Inferno::Test
    title 'Server returns AU PS Organization resource that matches the AU PS Organization profile'
    description %(
      This test will validate that the AU PS Organization resource returned from the server matches the AU PS Organization profile.
    )
    id :au_ps_au_ps_organization_entry_test
    
    optional
    
    uses_request :summary_operation

    run do
      initial_bundle = resource
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'Organization' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-organization')
      end
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'Organization' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-organization')
      end

      skip_if existing_resources.empty?, "No existing resources of type 'Organization' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-organization' found."

      existing_resources.each do |r|
        
        assert_valid_resource(resource: r, profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-organization')
        
      end
    end
  end
end
