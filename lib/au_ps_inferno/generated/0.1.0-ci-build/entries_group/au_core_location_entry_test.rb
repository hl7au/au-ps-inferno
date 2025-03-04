# frozen_string_literal: true

module AUPSTestKit
  class AuCoreLocationEntryTest < Inferno::TestGroup
    title 'AU Core Location'
    description 'TODO description: AuCoreLocationEntryTest'
    id :au_ps_au_core_location_entry_test

    test do
      title 'Server returns correct Location resource from the Location read interaction'
      description %(
        This test will verify that Location resources can be read from the server.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'Location' && r.meta&.profile&.include?('http://hl7.org.au/fhir/core/StructureDefinition/au-core-location')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'Location' with profile 'http://hl7.org.au/fhir/core/StructureDefinition/au-core-location' found."

        existing_resources.each do |r|
          fhir_read('Location', r.id)
          assert_response_status(200)
          assert_resource_type('Location')

          assert resource.id == r.id,
                 "Requested resource with id #{r.id}, received resource with id #{resource.id}"
        end
      end
    end

    test do
      title 'Server returns Location resource that matches the Location profile'
      description %(
        This test will validate that the Location resource returned from the server matches the Medication (IPS) profile.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'Location' && r.meta&.profile&.include?('http://hl7.org.au/fhir/core/StructureDefinition/au-core-location')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'Location' with profile 'http://hl7.org.au/fhir/core/StructureDefinition/au-core-location' found."

        existing_resources.each do |r|
          assert_valid_resource(resource: r, profile_url: 'http://hl7.org.au/fhir/core/StructureDefinition/au-core-location')
        end
      end
    end
  end
end
