# frozen_string_literal: true

module AUPSTestKit
  class AuPsEncounterEntryTest < Inferno::Test
    title 'Server returns AU PS Encounter resource that matches the AU PS Encounter profile'
    description %(
      This test will validate that the AU PS Encounter resource returned from the server matches the AU PS Encounter profile.
    )
    id :au_ps_au_ps_encounter_entry_test

    optional

    uses_request :summary_operation

    run do
      initial_bundle = resource
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'Encounter' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-encounter')
      end

      skip_if existing_resources.empty?,
              "No existing resources of type 'Encounter' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-encounter' found."

      existing_resources.each do |r|
        assert_valid_resource(resource: r, profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-encounter')
      end
    end
  end
end
