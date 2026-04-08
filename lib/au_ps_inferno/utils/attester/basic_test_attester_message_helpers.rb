# frozen_string_literal: true

module AUPSTestKit
  # Shared message formatting helpers for attester.party Must Support validation modules.
  module BasicTestAttesterMessageHelpers
    private

    def attester_party_join_message_sections(parts)
      parts.join("\n\n")
    end

    def attester_party_referenced_type_profile_header(resource_type_str, profile_str)
      "**Referenced attester.party**: #{resource_type_str}#{" — #{profile_str}" if profile_str.present?}"
    end
  end
end
