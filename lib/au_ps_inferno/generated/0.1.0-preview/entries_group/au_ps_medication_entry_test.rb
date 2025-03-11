# frozen_string_literal: true

module AUPSTestKit
  class AuPsMedicationEntryTest < Inferno::Test
    title 'Server returns AU PS Medication resource that matches the AU PS Medication profile'
    description %(
      This test will validate that the AU PS Medication resource returned from the server matches the AU PS Medication profile.
    )
    id :au_ps_au_ps_medication_entry_test
    
    optional
    
    uses_request :summary_operation

    run do
      initial_bundle = resource
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'Medication' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medication')
      end

      skip_if existing_resources.empty?, "No existing resources of type 'Medication' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medication' found."

      existing_resources.each do |r|
        assert_valid_resource(resource: r, profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medication')
      end
    end
  end
end
