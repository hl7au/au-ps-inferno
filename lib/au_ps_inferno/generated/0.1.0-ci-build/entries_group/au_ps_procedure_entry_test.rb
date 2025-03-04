# frozen_string_literal: true

module AUPSTestKit
  class AuPsProcedureEntryTest < Inferno::TestGroup
    title 'AU PS Procedure'
    description 'TODO description: AuPsProcedureEntryTest'
    id :au_ps_au_ps_procedure_entry_test

    test do
      title 'Server returns correct Procedure resource from the Procedure read interaction'
      description %(
        This test will verify that Procedure resources can be read from the server.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'Procedure' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-procedure')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'Procedure' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-procedure' found."

        existing_resources.each do |r|
          fhir_read('Procedure', r.id)
          assert_response_status(200)
          assert_resource_type('Procedure')

          assert resource.id == r.id,
                 "Requested resource with id #{r.id}, received resource with id #{resource.id}"
        end
      end
    end

    test do
      title 'Server returns Procedure resource that matches the Procedure profile'
      description %(
        This test will validate that the Procedure resource returned from the server matches the Medication (IPS) profile.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'Procedure' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-procedure')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'Procedure' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-procedure' found."

        existing_resources.each do |r|
          assert_valid_resource(resource: r, profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-procedure')
        end
      end
    end
  end
end
