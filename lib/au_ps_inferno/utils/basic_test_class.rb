# frozen_string_literal: true

require_relative 'constants'
require_relative 'bundle_decorator'

module AUPSTestKit
  # A base class for all tests to decrease code duplication
  class BasicTest < Inferno::Test
    extend Constants

    def scratch_bundle
      scratch[:bundle_ips_resource]
    end

    def check_bundle_exists_in_scratch
      skip_if scratch_bundle.blank?, 'No Bundle resource provided'
    end

    def check_other_sections
      check_bundle_exists_in_scratch
      composition_resource = BundleDecorator.new(scratch_bundle.to_hash).composition_resource
      other_section_codes = composition_resource.section_codes - Constants::ALL_SECTIONS
      info 'No other sections found' if other_section_codes.empty?
      other_section_codes.each do |section_code|
        check_composition_section_code(section_code, composition_resource)
      end
    end

    def check_composition_section_code(section_code, composition_resource)
      return unless section_code.present? || composition_resource.present?
      section = composition_resource.section_by_code(section_code)
      return if section_is_nil?(section, section_code)

      section_references_are_empty?(section, section_code)
      info "SECTION: #{section.code.coding.first.display}"
      section.entry_references.each do |ref|
        info BundleDecorator.new(scratch_bundle.to_hash).resource_info_by_entry_full_url(ref)
      end
    end

    def section_is_nil?(section, section_code)
      return unless section.nil?

      warning "Section #{section_code} not found in Composition resource"
      true
    end

    def section_references_are_empty?(section, section_code)
      return unless section.present?
      section_references = section.entry_references
      return unless section_references.empty?

      warning "Section #{section.code.coding.first.display}(#{section_code}) has no entries"
    end

    def composition_mandatory_ms_elements_info
      check_bundle_exists_in_scratch
      info "**List of Mandatory Must Support elements populated**:\n\n#{composition_mandatory_elements_info}"
      optional_elements = Constants::OPTIONAL_MS_ELEMENTS.map do |element|
        execute_statistics(composition_resource, element[:expression], element[:label])
      end.join("\n\n")
      info "**List of Optional Must Support elements populated**:\n\n#{optional_elements}"
    end

    def composition_mandatory_elements_info
      mandatory_elements = Constants::MANDATORY_MS_ELEMENTS.map do |element|
        execute_statistics(composition_resource, element[:expression], element[:label])
      end
      mandatory_elements.push(composition_section_title_info)
      mandatory_elements.push(composition_section_text_info)
      mandatory_elements.join("\n\n")
    end

    def composition_section_title_info
      "**section.title**: #{check_section_element_completeness('$.section.*.title')}"
    end

    def composition_section_text_info
      "**section.text**: #{check_section_element_completeness('$.section.*.text')}"
    end

    def check_section_element_completeness(json_path_expression)
      boolean_to_humanized_string(JsonPath.on(composition_resource,
                                              '$.section.*').length == JsonPath.on(
                                                composition_resource, json_path_expression
                                              ).length)
    end

    def composition_resource
      JsonPath.on(scratch_bundle.to_json, '$.entry[?(@.resource.resourceType == "Composition")].resource').first
    end

    def bundle_mandatory_ms_elements_info
      check_bundle_exists_in_scratch
      info "**Mandatory Must Support elements populated**:\n\n#{mandatory_ms_elements_info}"
      info "**List entry resource by type (and meta.profile if exists)**:\n\n#{entry_resources_info}"
    end

    def mandatory_ms_elements_info
      [
        "**identifier**: #{boolean_to_humanized_string(identifier_info)}",
        "**type**: #{boolean_to_humanized_string(type_info)}",
        "**timestamp**: #{boolean_to_humanized_string(timestamp_info)}",
        "**All entry exists fullUrl**: #{boolean_to_humanized_string(all_entries_have_full_url_info)}"
      ].join("\n\n")
    end

    def all_entries_have_full_url_info
      data_for_testing = scratch_bundle.to_json
      JsonPath.on(data_for_testing,
                  '$.entry[*].fullUrl').length == JsonPath.on(data_for_testing,
                                                              '$.entry[*]').length
    end

    def timestamp_info
      JsonPath.on(scratch_bundle.to_json, '$.timestamp').first.present?
    end

    def type_info
      JsonPath.on(scratch_bundle.to_json, '$.type').first.present?
    end

    def identifier_info
      JsonPath.on(scratch_bundle.to_json, '$.identifier').first.present?
    end

    def skip_validation?
      true
    end

    def validate_ips_bundle
      check_bundle_exists_in_scratch
      validate_bundle(
        scratch_bundle,
        'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle|0.4.0-draft'
      )
    end

    def read_composition_mandatory_sections_info
      read_composition_sections_info(Constants::MANDATORY_SECTIONS)
    end

    def read_composition_optional_sections_info
      read_composition_sections_info(Constants::OPTIONAL_SECTIONS)
    end

    def read_composition_recommended_sections_info
      read_composition_sections_info(Constants::RECOMMENDED_SECTIONS)
    end

    private

    def entry_resources_info
      JsonPath.on(scratch_bundle.to_json, '$.entry[*].resource').map do |resource|
        resource_type = JsonPath.on(resource, '$.resourceType').first
        profiles = JsonPath.on(resource, '$.meta.profile')
        result_message = profiles.empty? ? resource_type : "#{resource_type} (#{profiles.join(', ')})"
        result_message
      end.join("\n\n")
    end

    def validate_bundle(resource, profile_with_version)
      return if skip_validation?

      resource_is_valid?(resource: resource, profile_url: profile_with_version)
      errors_found = messages.any? { |message| message[:type] == 'error' }
      assert !errors_found, "Resource does not conform to the profile #{profile_with_version}"
    end

    def boolean_to_humanized_string(boolean_value)
      boolean_value ? 'Yes' : 'No'
    end

    def execute_statistics(json_data, json_path_expression, humanized_name)
      data_value = JsonPath.on(json_data, json_path_expression).first.present?
      "**#{humanized_name}**: #{boolean_to_humanized_string(data_value)}"
    end

    def read_composition_sections_info(sections_array_codes)
      check_bundle_exists_in_scratch
      sections_array_codes.each do |section_code|
        check_composition_section_code(section_code, BundleDecorator.new(scratch_bundle.to_hash).composition_resource)
      end
    end
  end
end
