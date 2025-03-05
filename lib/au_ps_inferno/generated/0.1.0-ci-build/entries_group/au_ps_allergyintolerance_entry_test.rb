# frozen_string_literal: true

module AUPSTestKit
  class AuPsAllergyintoleranceEntryTest < Inferno::Test
    title 'Server returns AU PS AllergyIntolerance resource that matches the AU PS AllergyIntolerance profile'
    description %(
      This test will validate that the AU PS AllergyIntolerance resource returned from the server matches the AU PS AllergyIntolerance profile.
    )
    id :au_ps_au_ps_allergyintolerance_entry_test

    optional

    uses_request :summary_operation

    run do
      initial_bundle = resource
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'AllergyIntolerance' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-allergyintolerance')
      end

      skip_if existing_resources.empty?,
              "No existing resources of type 'AllergyIntolerance' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-allergyintolerance' found."

      existing_resources.each do |r|
        assert_valid_resource(resource: r, profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-allergyintolerance')
      end
    end
  end
end
