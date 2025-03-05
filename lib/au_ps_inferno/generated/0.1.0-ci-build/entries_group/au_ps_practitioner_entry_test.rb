# frozen_string_literal: true

module AUPSTestKit
  class AuPsPractitionerEntryTest < Inferno::Test
    title 'Server returns AU PS Practitioner resource that matches the AU PS Practitioner profile'
    description %(
      This test will validate that the AU PS Practitioner resource returned from the server matches the AU PS Practitioner profile.
    )
    id :au_ps_au_ps_practitioner_entry_test

    optional

    uses_request :summary_operation

    run do
      initial_bundle = resource
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'Practitioner' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-practitioner')
      end

      skip_if existing_resources.empty?,
              "No existing resources of type 'Practitioner' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-practitioner' found."

      existing_resources.each do |r|
        assert_valid_resource(resource: r, profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-practitioner')
      end
    end
  end
end
