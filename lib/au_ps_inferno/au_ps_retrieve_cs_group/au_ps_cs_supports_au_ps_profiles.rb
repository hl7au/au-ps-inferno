# frozen_string_literal: true

require 'jsonpath'
require_relative '../utils/constants'

module AUPSTestKit
  class AUPSCSSupportsAUPSProfiles < Inferno::Test
    include Constants

    title TEXTS[:au_ps_cs_supports_au_ps_profiles][:title]
    description TEXTS[:au_ps_cs_supports_au_ps_profiles][:description]
    id :au_ps_cs_supports_au_ps_profiles

    def check_profiles_status(cs_resource, profiles_mapping, general_message)
      profile = JsonPath.on(cs_resource.to_json, "$.rest.*.resource.*.profile")
      supported_profile = JsonPath.on(cs_resource.to_json, "$.rest.*.resource.*.supportedProfile")
      all_profiles = (profile + supported_profile).uniq

      au_ps_profiles_status_array = profiles_mapping.keys.map do |profile_url|
        if all_profiles.include?(profile_url)
          "#{profiles_mapping[profile_url]} (#{profile_url}): Yes"
        else
          "#{profiles_mapping[profile_url]} (#{profile_url}): No"
        end
      end.join("\n\n")
      info "**#{general_message}**:\n\n#{au_ps_profiles_status_array}"
    end

    run do
      check_profiles_status(
        scratch[:capability_statement],
        AU_PS_PROFILES_MAPPING_REQUIRED,
        "For each of the following AU PS profiles indicate if it is referenced as a supported profile")

      check_profiles_status(
        scratch[:capability_statement],
        AU_PS_PROFILES_MAPPING_OTHER,
        "List any other AU PS profiles referenced as supported profile")
    end
  end
end
