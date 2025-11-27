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

      show_message("Mandatory Must Support elements populated: identifier: #{identifier}", identifier)
      show_message("Mandatory Must Support elements populated: type: #{type}", type)
      show_message("Mandatory Must Support elements populated: timestamp: #{timestamp}", timestamp)
      show_message("Mandatory Must Support elements populated: All entry exists fullUrl: #{all_entries_have_full_url}", all_entries_have_full_url)

      info "List entry resource by type (and meta.profile if exists):"
      JsonPath.on(data_for_testing, '$.entry[*].resource').each do |resource|
        resource_type = JsonPath.on(resource, '$.resourceType').first
        profiles = JsonPath.on(resource, '$.meta.profile')
        result_message = profiles.empty? ? resource_type : "#{resource_type} (#{profiles.join(', ')})"

        info result_message
      end
    end

    run do
      bundle_mandatory_ms_elements_info
    end
  end
end
