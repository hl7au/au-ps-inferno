# frozen_string_literal: true

module AUPSTestKit
  class AuPsOrganizationEntryTest < Inferno::TestGroup
    title 'AU PS Organization'
    description 'TODO description: AuPsOrganizationEntryTest'
    id :au_ps_au_ps_organization_entry_test

    test do
      title 'Server returns correct Organization resource from the Organization read interaction'
      description %(
        This test will verify that Organization resources can be read from the server.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'Organization' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-organization')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'Organization' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-organization' found."

        existing_resources.each do |r|
          fhir_read('Organization', r.id)
          assert_response_status(200)
          assert_resource_type('Organization')

          assert resource.id == r.id,
                 "Requested resource with id #{r.id}, received resource with id #{resource.id}"
        end
      end
    end

    test do
      title 'Server returns Organization resource that matches the Organization profile'
      description %(
        This test will validate that the Organization resource returned from the server matches the Medication (IPS) profile.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'Organization' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-organization')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'Organization' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-organization' found."

        existing_resources.each do |r|
          assert_valid_resource(resource: r, profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-organization')
        end
      end
    end
  end
end
