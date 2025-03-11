# frozen_string_literal: true

module AUPSTestKit
  class AuPsConditionEntryTest < Inferno::Test
    title 'Server returns AU PS Condition resource that matches the AU PS Condition profile'
    description %(
      This test will validate that the AU PS Condition resource returned from the server matches the AU PS Condition profile.
    )
    id :au_ps_au_ps_condition_entry_test
    
    optional
    
    uses_request :summary_operation

    run do
      initial_bundle = resource
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'Condition' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition')
      end

      skip_if existing_resources.empty?, "No existing resources of type 'Condition' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition' found."

      existing_resources.each do |r|
        assert_valid_resource(resource: r, profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-condition')
      end
    end
  end
end
