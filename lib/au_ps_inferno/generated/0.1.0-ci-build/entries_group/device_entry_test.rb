# frozen_string_literal: true

module AUPSTestKit
  class DeviceEntryTest < Inferno::TestGroup
    title 'Device'
    description 'TODO description: DeviceEntryTest'
    id :au_ps_device_entry_test

    test do
      title 'Server returns correct Device resource from the Device read interaction'
      description %(
        This test will verify that Device resources can be read from the server.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'Device' && r.meta&.profile&.include?('')
        end

        skip_if existing_resources.empty?, "No existing resources of type 'Device' with profile '' found."

        existing_resources.each do |r|
          fhir_read('Device', r.id)
          assert_response_status(200)
          assert_resource_type('Device')

          assert resource.id == r.id,
                 "Requested resource with id #{r.id}, received resource with id #{resource.id}"
        end
      end
    end

    test do
      title 'Server returns Device resource that matches the Device profile'
      description %(
        This test will validate that the Device resource returned from the server matches the Medication (IPS) profile.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'Device' && r.meta&.profile&.include?('')
        end

        skip_if existing_resources.empty?, "No existing resources of type 'Device' with profile '' found."

        existing_resources.each do |r|
          assert_valid_resource(resource: r, profile_url: '')
        end
      end
    end
  end
end
