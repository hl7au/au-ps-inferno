# frozen_string_literal: true

module AUPSTestKit
  class ObservationSocialHistoryAlcoholUseIpsEntryTest < Inferno::Test
    title 'Server returns Observation Social History - Alcohol Use (IPS) resource that matches the Observation Social History - Alcohol Use (IPS) profile'
    description %(
      This test will validate that the Observation Social History - Alcohol Use (IPS) resource returned from the server matches the Observation Social History - Alcohol Use (IPS) profile.
    )
    id :au_ps_observation_social_history_alcohol_use_ips_entry_test

    optional

    uses_request :summary_operation

    run do
      initial_bundle = resource
      existing_resources = initial_bundle.entry.map(&:resource).select do |r|
        r.resourceType == 'Observation' && r.meta&.profile&.include?('http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-alcoholuse-uv-ips')
      end

      skip_if existing_resources.empty?,
              "No existing resources of type 'Observation' with profile 'http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-alcoholuse-uv-ips' found."

      existing_resources.each do |r|
        assert_valid_resource(resource: r, profile_url: 'http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-alcoholuse-uv-ips')
      end
    end
  end
end
