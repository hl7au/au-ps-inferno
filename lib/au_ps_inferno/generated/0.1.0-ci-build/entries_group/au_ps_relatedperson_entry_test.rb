# frozen_string_literal: true

module AUPSTestKit
  class AuPsRelatedpersonEntryTest < Inferno::Test
    title 'Server returns AU PS RelatedPerson resource that matches the AU PS RelatedPerson profile'
    description %(
      This test will validate that the AU PS RelatedPerson resource returned from the server matches the AU PS RelatedPerson profile.
    )
    id :au_ps_au_ps_relatedperson_entry_test

    optional

    uses_request :summary_operation

    run do
      initial_bundle = resource
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'RelatedPerson' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-relatedperson')
      end

      skip_if existing_resources.empty?,
              "No existing resources of type 'RelatedPerson' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-relatedperson' found."

      existing_resources.each do |r|
        assert_valid_resource(resource: r, profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-relatedperson')
      end
    end
  end
end
