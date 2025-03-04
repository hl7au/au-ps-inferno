# frozen_string_literal: true

module AUPSTestKit
  class FlagAlertIpsEntryTest < Inferno::TestGroup
    title 'Flag - Alert (IPS)'
    description 'TODO description: FlagAlertIpsEntryTest'
    id :au_ps_flag_alert_ips_entry_test

    test do
      title 'Server returns correct Flag resource from the Flag read interaction'
      description %(
        This test will verify that Flag resources can be read from the server.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'Flag' && r.meta&.profile&.include?('http://hl7.org/fhir/uv/ips/StructureDefinition/Flag-alert-uv-ips')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'Flag' with profile 'http://hl7.org/fhir/uv/ips/StructureDefinition/Flag-alert-uv-ips' found."

        existing_resources.each do |r|
          fhir_read('Flag', r.id)
          assert_response_status(200)
          assert_resource_type('Flag')

          assert resource.id == r.id,
                 "Requested resource with id #{r.id}, received resource with id #{resource.id}"
        end
      end
    end

    test do
      title 'Server returns Flag resource that matches the Flag profile'
      description %(
        This test will validate that the Flag resource returned from the server matches the Medication (IPS) profile.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'Flag' && r.meta&.profile&.include?('http://hl7.org/fhir/uv/ips/StructureDefinition/Flag-alert-uv-ips')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'Flag' with profile 'http://hl7.org/fhir/uv/ips/StructureDefinition/Flag-alert-uv-ips' found."

        existing_resources.each do |r|
          assert_valid_resource(resource: r, profile_url: 'http://hl7.org/fhir/uv/ips/StructureDefinition/Flag-alert-uv-ips')
        end
      end
    end
  end
end
