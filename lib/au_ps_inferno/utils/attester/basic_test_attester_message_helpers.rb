# frozen_string_literal: true

module AUPSTestKit
  # Shared message formatting helpers for attester.party Must Support validation modules.
  module BasicTestAttesterMessageHelpers
    private

    def attester_party_join_message_sections(parts)
      parts.join("\n\n")
    end

    def attester_party_ms_element_list_lines(resource, expressions)
      expressions.map do |expr|
        populated = resolve_path_with_dar(resource, expr).first.present?
        mandatory = metadata_manager.get_attester_mandatory_elements_by_resource_type(
          resource_type(resource)
        ).include?(expr)
        "#{boolean_to_existent_string(populated)}: **#{expr}**#{mandatory ? ' (Mandatory)' : ' (Optional)'}"
      end
    end

    def attester_party_referenced_type_profile_header(resource_type_str, profile_str)
      "**Referenced attester.party**: #{resource_type_str}#{" — #{profile_str}" if profile_str.present?}"
    end
  end
end
