# frozen_string_literal: true

module AUPSTestKit
  class DiagnosticreportIpsEntryTest < Inferno::TestGroup
    title 'DiagnosticReport (IPS)'
    description 'TODO description: DiagnosticreportIpsEntryTest'
    id :au_ps_diagnosticreport_ips_entry_test

    test do
      title 'Server returns correct DiagnosticReport resource from the DiagnosticReport read interaction'
      description %(
        This test will verify that DiagnosticReport resources can be read from the server.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'DiagnosticReport' && r.meta&.profile&.include?('http://hl7.org/fhir/uv/ips/StructureDefinition/DiagnosticReport-uv-ips')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'DiagnosticReport' with profile 'http://hl7.org/fhir/uv/ips/StructureDefinition/DiagnosticReport-uv-ips' found."

        existing_resources.each do |r|
          fhir_read('DiagnosticReport', r.id)
          assert_response_status(200)
          assert_resource_type('DiagnosticReport')

          assert resource.id == r.id,
                 "Requested resource with id #{r.id}, received resource with id #{resource.id}"
        end
      end
    end

    test do
      title 'Server returns DiagnosticReport resource that matches the DiagnosticReport profile'
      description %(
        This test will validate that the DiagnosticReport resource returned from the server matches the Medication (IPS) profile.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'DiagnosticReport' && r.meta&.profile&.include?('http://hl7.org/fhir/uv/ips/StructureDefinition/DiagnosticReport-uv-ips')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'DiagnosticReport' with profile 'http://hl7.org/fhir/uv/ips/StructureDefinition/DiagnosticReport-uv-ips' found."

        existing_resources.each do |r|
          assert_valid_resource(resource: r, profile_url: 'http://hl7.org/fhir/uv/ips/StructureDefinition/DiagnosticReport-uv-ips')
        end
      end
    end
  end
end
