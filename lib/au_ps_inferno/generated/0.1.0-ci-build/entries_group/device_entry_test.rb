# frozen_string_literal: true

module AUPSTestKit
  class DeviceEntryTest < Inferno::Test
    title 'Server returns Device resource that matches the Device profile'
    description %(
      This test will validate that the Device resource returned from the server matches the Device profile.
    )
    id :au_ps_device_entry_test

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
