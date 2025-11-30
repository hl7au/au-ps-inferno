# frozen_string_literal: true

# Utilities for FHIR Composition resources
module CompositionUtils
  def scratch_bundle
    scratch[:bundle_ips_resource]
  end

  def check_bundle_exists_in_scratch
    skip_if scratch_bundle.blank?, 'No Bundle resource provided'
  end

  def check_composition_section_code(section_code, composition_resource)
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

  def boolean_to_humanized_string(boolean_value)
    boolean_value ? 'Yes' : 'No'
  end

  def execute_statistics(json_data, json_path_expression, humanized_name)
    data_value = JsonPath.on(json_data, json_path_expression).first.present?
    "**#{humanized_name}**: #{boolean_to_humanized_string(data_value)}"
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
end
