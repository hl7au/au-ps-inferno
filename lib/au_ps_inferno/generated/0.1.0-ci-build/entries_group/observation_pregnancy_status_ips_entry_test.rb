# frozen_string_literal: true

module AUPSTestKit
  class ObservationPregnancyStatusIpsEntryTest < Inferno::Test
    title 'Server returns Observation Pregnancy - Status (IPS) resource that matches the Observation Pregnancy - Status (IPS) profile'
    description %(
      This test will validate that the Observation Pregnancy - Status (IPS) resource returned from the server matches the Observation Pregnancy - Status (IPS) profile.
    )
    id :au_ps_observation_pregnancy_status_ips_entry_test

    optional

    uses_request :summary_operation

    run do
      initial_bundle = resource
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'Observation' && r.meta&.profile&.include?('http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-pregnancy-status-uv-ips')
      end

      skip_if existing_resources.empty?,
              "No existing resources of type 'Observation' with profile 'http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-pregnancy-status-uv-ips' found."

      existing_resources.each do |r|
        assert_valid_resource(resource: r, profile_url: 'http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-pregnancy-status-uv-ips')
      end
    end
  end
end
