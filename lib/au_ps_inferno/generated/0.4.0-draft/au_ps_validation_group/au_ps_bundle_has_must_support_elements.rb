# frozen_string_literal: true

require 'jsonpath'
require_relative '../../../utils/basic_test_class'

module AUPSTestKit
  class AUPSBundleHasMUSTSUPPORTElements < BasicTest
    title 'Bundle has mandatory must-support elements'
    description 'Checks that the Bundle resource contains mandatory must-support elements (identifier, type, timestamp) and that all entries have a fullUrl. Also provides information about the resource types included in the Bundle.'
    id :au_ps_bundle_has_must_support_elements

    def bundle_mandatory_ms_elements_info
      data_for_testing = scratch[:ips_bundle_resource].to_json
      identifier = JsonPath.on(data_for_testing, '$.identifier').first.present?
      type = JsonPath.on(data_for_testing, '$.type').first.present?
      timestamp = JsonPath.on(data_for_testing, '$.timestamp').first.present?
      all_entries_have_full_url = JsonPath.on(data_for_testing, '$.entry[*].fullUrl').length == JsonPath.on(data_for_testing, '$.entry[*]').length

      ms_elements_array = ["**identifier**: #{boolean_to_humanized_string(identifier)}", "**type**: #{boolean_to_humanized_string(type)}",
                           "**timestamp**: #{boolean_to_humanized_string(timestamp)}", "**All entry exists fullUrl**: #{boolean_to_humanized_string(all_entries_have_full_url)}"].join("\n\n")
      info "**Mandatory Must Support elements populated**:\n\n#{ms_elements_array}"

      entry_resources_array = JsonPath.on(data_for_testing, '$.entry[*].resource').map do |resource|
        resource_type = JsonPath.on(resource, '$.resourceType').first
        profiles = JsonPath.on(resource, '$.meta.profile')
        result_message = profiles.empty? ? resource_type : "#{resource_type} (#{profiles.join(", ")})"

        result_message
      end.join("\n\n")
      info "**List entry resource by type (and meta.profile if exists)**:\n\n#{entry_resources_array}"
    end

    run do
      bundle_mandatory_ms_elements_info
    end
  end
end
