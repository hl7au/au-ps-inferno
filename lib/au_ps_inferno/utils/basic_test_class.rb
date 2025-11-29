# frozen_string_literal: true

require_relative 'constants'
require_relative 'bundle_decorator'

module AUPSTestKit
  class BasicTest < Inferno::Test
    include Constants

    def check_other_sections
      au_ps_bundle_resource = BundleDecorator.new(scratch[:ips_bundle_resource].to_hash)
      composition_resource = au_ps_bundle_resource.composition_resource
      other_section_codes = composition_resource.section_codes - ALL_SECTIONS
      if other_section_codes.empty?
        info 'No other sections found'
      else
        other_section_codes.each do |section_code|
          section = composition_resource.section_by_code(section_code)
          if section.nil?
            warning "Section #{section_code} not found in Composition resource"
            next
          end
          section_references = section.entry_references
          if section_references.empty?
            warning "Section #{section.code.coding.first.display}(#{section_code}) has no entries"
          else
            info "SECTION: #{section.code.coding.first.display}"
            section.entry_references.each do |ref|
              info au_ps_bundle_resource.resource_info_by_entry_full_url(ref)
            end
          end
        end
      end
    end

    def composition_mandatory_ms_elements_info
      composition_resource = JsonPath.on(scratch[:ips_bundle_resource].to_json,
                                         '$.entry[?(@.resource.resourceType == "Composition")].resource').first

      mandatory_elements = MANDATORY_MS_ELEMENTS.map do |element|
        execute_statistics(composition_resource, element[:expression], element[:label])
      end
      section_title = JsonPath.on(composition_resource,
                                  '$.section.*').length == JsonPath.on(composition_resource, '$.section.*.title').length
      section_text = JsonPath.on(composition_resource,
                                 '$.section.*').length == JsonPath.on(composition_resource, '$.section.*.text').length
      mandatory_elements.push("**section.title**: #{boolean_to_humanized_string(section_title)}")
      mandatory_elements.push("**section.text**: #{boolean_to_humanized_string(section_text)}")
      info "**List of Mandatory Must Support elements populated**:\n\n#{mandatory_elements.join("\n\n")}"

      optional_elements = OPTIONAL_MS_ELEMENTS.map do |element|
        execute_statistics(composition_resource, element[:expression], element[:label])
      end.join("\n\n")
      info "**List of Optional Must Support elements populated**:\n\n#{optional_elements}"
    end

    def bundle_mandatory_ms_elements_info
      data_for_testing = scratch[:ips_bundle_resource].to_json
      identifier = JsonPath.on(data_for_testing, '$.identifier').first.present?
      type = JsonPath.on(data_for_testing, '$.type').first.present?
      timestamp = JsonPath.on(data_for_testing, '$.timestamp').first.present?
      all_entries_have_full_url = JsonPath.on(data_for_testing,
                                              '$.entry[*].fullUrl').length == JsonPath.on(data_for_testing,
                                                                                          '$.entry[*]').length

      ms_elements_array = ["**identifier**: #{boolean_to_humanized_string(identifier)}", "**type**: #{boolean_to_humanized_string(type)}",
                           "**timestamp**: #{boolean_to_humanized_string(timestamp)}", "**All entry exists fullUrl**: #{boolean_to_humanized_string(all_entries_have_full_url)}"].join("\n\n")
      info "**Mandatory Must Support elements populated**:\n\n#{ms_elements_array}"

      entry_resources_array = JsonPath.on(data_for_testing, '$.entry[*].resource').map do |resource|
        resource_type = JsonPath.on(resource, '$.resourceType').first
        profiles = JsonPath.on(resource, '$.meta.profile')
        result_message = profiles.empty? ? resource_type : "#{resource_type} (#{profiles.join(', ')})"

        result_message
      end.join("\n\n")
      info "**List entry resource by type (and meta.profile if exists)**:\n\n#{entry_resources_array}"
    end

    def skip_validation?
      true
    end

    def validate_bundle(resource, profile_with_version)
      return if skip_validation?

      resource_is_valid?(resource: resource, profile_url: profile_with_version)
      errors_found = messages.any? { |message| message[:type] == 'error' }
      assert !errors_found, "Resource does not conform to the profile #{profile_with_version}"
    end

    def validate_ips_bundle
      validate_bundle(
        scratch[:ips_bundle_resource],
        'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle|0.4.0-draft'
      )
    end

    def show_message(message, state_value)
      if state_value
        info message
      else
        warning message
      end
    end

    def boolean_to_humanized_string(boolean_value)
      boolean_value ? 'Yes' : 'No'
    end

    def execute_statistics(json_data, json_path_expression, humanized_name)
      data_value = JsonPath.on(json_data, json_path_expression).first.present?
      "**#{humanized_name}**: #{boolean_to_humanized_string(data_value)}"
    end

    def get_composition_sections_info(sections_array_codes)
      au_ps_bundle_resource = BundleDecorator.new(scratch[:ips_bundle_resource].to_hash)
      composition_resource = au_ps_bundle_resource.composition_resource
      sections_array_codes.each do |section_code|
        section = composition_resource.section_by_code(section_code)
        if section.nil?
          warning "Section #{section_code} not found in Composition resource"
          next
        end
        section_references = section.entry_references
        if section_references.empty?
          warning "Section #{section.code.coding.first.display}(#{section_code}) has no entries"
        else
          section_resources_array = section.entry_references.map do |ref|
            au_ps_bundle_resource.resource_info_by_entry_full_url(ref)
          end.join("\n\n")
          info "**Section #{section.code.coding.first.display}**:\n\n#{section_resources_array}"
        end
      end
    end
  end
end
