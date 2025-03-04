# frozen_string_literal: true

module AUPSTestKit
  class AuPsAllergyintoleranceEntryTest < Inferno::TestGroup
    title 'AU PS AllergyIntolerance'
    description 'TODO description: AuPsAllergyintoleranceEntryTest'
    id :au_ps_au_ps_allergyintolerance_entry_test

    test do
      title 'Server returns correct AllergyIntolerance resource from the AllergyIntolerance read interaction'
      description %(
        This test will verify that AllergyIntolerance resources can be read from the server.
      )

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
          fhir_read('AllergyIntolerance', r.id)
          assert_response_status(200)
          assert_resource_type('AllergyIntolerance')

          assert resource.id == r.id,
                 "Requested resource with id #{r.id}, received resource with id #{resource.id}"
        end
      end
    end

    test do
      title 'Server returns AllergyIntolerance resource that matches the AllergyIntolerance profile'
      description %(
        This test will validate that the AllergyIntolerance resource returned from the server matches the Medication (IPS) profile.
      )

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
end
