# frozen_string_literal: true

require 'jsonpath'

module AUPSTestKit
  class SummaryOperationReturnBundle < Inferno::Test
    title 'Return a valid Bundle for $summary or validate a provided Bundle'
    description 'Validates that a Bundle resource conforms to the AU PS Bundle profile. This test either makes a $summary operation request to retrieve and validate a Bundle, or validates a provided Bundle resource.'
    id :au_ps_summary_operation_return_bundle

    input :patient_id,
          optional: true,
          description: 'To request Patient/{patient_id}/$summary'

    input :identifier,
          optional: true,
          description: 'To request Patient/$summary?identifier={identifier}'

    input :bundle_resource,
          optional: true,
          description: 'If you want to check existing Bundle resource',
          type: 'textarea'

    makes_request :summary_operation

    def get_and_save_data(bundle_resource)
      if bundle_resource.present?
        info 'Using provided Bundle resource'
        resource = FHIR.from_contents(bundle_resource)
        scratch[:ips_bundle_resource] = resource
      else
        info 'Making $summary operation request'
        operation_path = if patient_id
                           "Patient/#{patient_id}/$summary"
                         else
                           "Patient/$summary?identifier=#{identifier}"
                         end
        response = fhir_operation(operation_path, name: :summary_operation, operation_method: :get)
        resource_from_request = FHIR.from_contents(response.response_body)
        scratch[:ips_bundle_resource] = resource_from_request
      end
      info "Bundle resource saved to scratch: #{scratch[:ips_bundle_resource]}"
    end

    def validate_bundle(resource, profile_with_version)
      resource_is_valid?(resource: resource, profile_url: profile_with_version)
      errors_found = messages.any? { |message| message[:type] == "error" }
      assert !errors_found, "Resource does not conform to the profile #{profile_with_version}"
    end

    def show_message(message, state_value)
      if state_value
        info message
      else
        warning message
      end
    end

    def bundle_mandatory_ms_elements_info
      data_for_testing = scratch[:ips_bundle_resource].to_json
      info "data_for_testing: #{data_for_testing}"
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
      get_and_save_data(bundle_resource)
      bundle_mandatory_ms_elements_info
      validate_bundle(
        scratch[:ips_bundle_resource],
        'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle|0.4.0-draft')
    end
  end
end
