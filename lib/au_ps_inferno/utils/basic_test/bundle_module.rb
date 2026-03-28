# frozen_string_literal: true

module AUPSTestKit
  # Bundle-level checks, mandatory MS list info, and IPS bundle profile validation.
  module BasicTestBundleModule
    def check_other_sections(all_sections_data_codes, sections_codes_mapping)
      check_bundle_exists_in_scratch
      composition_resource = BundleDecorator.new(scratch_bundle.to_hash).composition_resource
      other_section_codes = composition_resource.section_codes - all_sections_data_codes
      info 'No other sections found' if other_section_codes.empty?
      other_section_codes.each do |section_code|
        check_composition_section_code(section_code, composition_resource, sections_codes_mapping)
      end
    end

    def bundle_mandatory_ms_elements_info
      check_bundle_exists_in_scratch
      passed = [identifier_info?, type_info?, timestamp_info?, all_entries_have_full_url_info?].all?
      message_type = passed ? 'info' : 'error'
      add_message(message_type,
                  "**List mandatory Must Support elements populated and missing**:\n\n#{mandatory_ms_elements_info}")
      info "**List any entry resources by type (and meta.profile if exists)**:\n\n#{entry_resources_info}"
      assert passed, 'Mandatory Must Support elements are not populated'
    end

    def mandatory_ms_elements_info
      [
        "**identifier**: #{boolean_to_existent_string(identifier_info?)}",
        "**type**: #{boolean_to_existent_string(type_info?)}",
        "**timestamp**: #{boolean_to_existent_string(timestamp_info?)}",
        "**All entry exists fullUrl**: #{boolean_to_existent_string(all_entries_have_full_url_info?)}"
      ].join("\n\n")
    end

    def skip_validation?
      false
    end

    def validate_ips_bundle
      check_bundle_exists_in_scratch
      validate_bundle(
        scratch_bundle,
        'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle|1.0.0-ballot'
      )
    end

    private

    def validate_bundle(resource, profile_with_version)
      return if skip_validation?

      show_validator_version

      resource_is_valid?(resource: resource, profile_url: profile_with_version)
      errors_found = messages.any? { |message| message[:type] == 'error' }
      assert !errors_found, "Resource does not conform to the profile #{profile_with_version}"
    end
  end
end
