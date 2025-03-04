# frozen_string_literal: true

module AUPSTestKit
  class DeviceusestatementIpsEntryTest < Inferno::TestGroup
    title 'DeviceUseStatement (IPS)'
    description 'TODO description: DeviceusestatementIpsEntryTest'
    id :au_ps_deviceusestatement_ips_entry_test

    test do
      title 'Server returns correct DeviceUseStatement resource from the DeviceUseStatement read interaction'
      description %(
        This test will verify that DeviceUseStatement resources can be read from the server.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'DeviceUseStatement' && r.meta&.profile&.include?('http://hl7.org/fhir/uv/ips/StructureDefinition/DeviceUseStatement-uv-ips')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'DeviceUseStatement' with profile 'http://hl7.org/fhir/uv/ips/StructureDefinition/DeviceUseStatement-uv-ips' found."

        existing_resources.each do |r|
          fhir_read('DeviceUseStatement', r.id)
          assert_response_status(200)
          assert_resource_type('DeviceUseStatement')

          assert resource.id == r.id,
                 "Requested resource with id #{r.id}, received resource with id #{resource.id}"
        end
      end
    end

    test do
      title 'Server returns DeviceUseStatement resource that matches the DeviceUseStatement profile'
      description %(
        This test will validate that the DeviceUseStatement resource returned from the server matches the Medication (IPS) profile.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'DeviceUseStatement' && r.meta&.profile&.include?('http://hl7.org/fhir/uv/ips/StructureDefinition/DeviceUseStatement-uv-ips')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'DeviceUseStatement' with profile 'http://hl7.org/fhir/uv/ips/StructureDefinition/DeviceUseStatement-uv-ips' found."

        existing_resources.each do |r|
          assert_valid_resource(resource: r, profile_url: 'http://hl7.org/fhir/uv/ips/StructureDefinition/DeviceUseStatement-uv-ips')
        end
      end
    end
  end
end
