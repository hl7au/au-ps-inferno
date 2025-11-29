# frozen_string_literal: true

require 'jsonpath'
require_relative '../utils/basic_test_class'

module AUPSTestKit
  # AU PS Profiles referenced as supported in CapabilityStatement
  class AUPSCSSupportsAUPSProfiles < BasicTest
    title t_title(:au_ps_cs_supports_au_ps_profiles)
    description t_description(:au_ps_cs_supports_au_ps_profiles)
    id :au_ps_cs_supports_au_ps_profiles

    def check_profiles_status(cs_resource, profiles_mapping, general_message)
      all_profiles = (JsonPath.on(cs_resource.to_json, '$.rest.*.resource.*.profile')
                      + JsonPath.on(cs_resource.to_json, '$.rest.*.resource.*.supportedProfile')).uniq
      au_ps_profiles_status_array = profiles_mapping.keys.map do |profile_url|
        "#{profiles_mapping[profile_url]} (#{profile_url}): #{all_profiles.include?(profile_url) ? 'Yes' : 'No'}"
      end.join("\n\n")
      info "**#{general_message}**:\n\n#{au_ps_profiles_status_array}"
    end

    run do
      skip_if scratch[:capability_statement].blank?, 'No CapabilityStatement resource provided'
      check_profiles_status(
        scratch[:capability_statement],
        Constants::AU_PS_PROFILES_MAPPING_REQUIRED,
        'For each of the following AU PS profiles indicate if it is referenced as a supported profile'
      )

      check_profiles_status(
        scratch[:capability_statement],
        Constants::AU_PS_PROFILES_MAPPING_OTHER,
        'List any other AU PS profiles referenced as supported profile'
      )
    end
  end
end
