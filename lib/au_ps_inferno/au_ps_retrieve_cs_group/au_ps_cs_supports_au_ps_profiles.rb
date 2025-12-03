# frozen_string_literal: true

require_relative '../utils/basic_test_class'
require_relative '../utils/capability_statement_decorator'

module AUPSTestKit
  # AU PS Profiles referenced as supported in CapabilityStatement
  class AUPSCSSupportsAUPSProfiles < BasicTest
    title 'CapabilityStatement supports AU PS Profiles'
    description 'AU PS Profiles referenced as supported in CapabilityStatement'
    id :au_ps_cs_supports_au_ps_profiles

    def check_profiles_status(profiles_mapping, general_message)
      au_ps_profiles_status_array = profiles_mapping.keys.map do |profile_url|
        "#{profiles_mapping[profile_url]} (#{profile_url}): #{cs_profiles.include?(profile_url) ? 'Yes' : 'No'}"
      end.join("\n\n")
      info "**#{general_message}**:\n\n#{au_ps_profiles_status_array}"
    end

    def cs_profiles
      cs_resource = CapabilityStatementDecorator.new(scratch[:capability_statement].to_hash)
      cs_resource.all_profiles
    end

    run do
      skip_if scratch[:capability_statement].blank?, 'No CapabilityStatement resource provided'
      check_profiles_status(
        Constants::AU_PS_PROFILES_MAPPING_REQUIRED,
        'For each of the following AU PS profiles indicate if it is referenced as a supported profile'
      )

      check_profiles_status(
        Constants::AU_PS_PROFILES_MAPPING_OTHER,
        'List any other AU PS profiles referenced as supported profile'
      )
    end
  end
end
