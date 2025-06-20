# frozen_string_literal: true

module AUPSTestKit
  class AuPsPractitionerroleEntryTest < Inferno::Test
    title 'Server returns AU PS PractitionerRole resource that matches the AU PS PractitionerRole profile'
    description %(
      This test will validate that the AU PS PractitionerRole resource returned from the server matches the AU PS PractitionerRole profile.
    )
    id :au_ps_au_ps_practitionerrole_entry_test
    
    optional
    
    uses_request :summary_operation

    run do
      initial_bundle = resource
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'PractitionerRole' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-practitionerrole')
      end
      
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'PractitionerRole' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-practitionerrole')
      end

      skip_if existing_resources.empty?, "No existing resources of type 'PractitionerRole' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-practitionerrole' found."

      existing_resources.each do |r|
        
        assert_valid_resource(resource: r, profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-practitionerrole')
        
      end
    end
  end
end
