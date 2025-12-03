# frozen_string_literal: true

require_relative 'bundle_decorator'

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
    sections_info = group_section_output(section.entry_references.map do |ref|
      BundleDecorator.new(scratch_bundle.to_hash).resource_info_by_entry_full_url(ref)
    end).join("\n\n") || section.empty_reason_str
    return unless sections_info.present?

    info "SECTION: #{section.code_display_str}\n\n#{sections_info}"
  end

  def group_section_output(section_info_array)
    section_entities = {}
    section_info_array.each do |section_info|
      if section_entities.keys.include?(section_info)
        section_entities[section_info] += 1
      else
        section_entities[section_info] = 1
      end
    end
    section_entities.keys.map { |section_entity| "#{section_entity} x#{section_entities[section_entity]}" }
  end

  def section_is_nil?(section, section_code)
    return unless section.nil?

    warning "Section #{sections_codes[section_code]} (#{section_code}) not found in Composition resource"
    true
  end

  def sections_codes
    Constants::SECTIONS_CODES_MAPPING
  end

  def section_references_are_empty?(section, section_code)
    return unless section.present?

    section_references = section.entry_references
    return unless section_references.empty?

    empty_reason_str = section.empty_reason_str
    if empty_reason_str.present?
      warning "Section #{section.code.coding.first.display}(#{section_code}) has no entries because #{empty_reason_str}"
    else
      warning "Section #{section.code.coding.first.display}(#{section_code}) has no entries"
    end
  end

  def boolean_to_humanized_string(boolean_value)
    boolean_value ? 'Yes' : 'No'
  end

  def execute_statistics(resource, path_expression, humanized_name)
    data_value = resolve_path(resource, path_expression).first.present?
    boolean_value = boolean_to_humanized_string(data_value)
    "**#{humanized_name}**: #{boolean_value}"
  end

  def all_entries_have_full_url_info
    entry_full_url_count = resolve_path(scratch_bundle, 'entry.fullUrl').length
    entries_count = resolve_path(scratch_bundle, 'entry').length

    entry_full_url_count == entries_count
  end

  def timestamp_info
    resolve_path(scratch_bundle, 'timestamp').first.present?
  end

  def type_info
    resolve_path(scratch_bundle, 'type').first.present?
  end

  def identifier_info
    resolve_path(scratch_bundle, 'identifier').first.present?
  end

  def composition_section_title_info
    "**section.title**: #{check_section_element_completeness('section.title')}"
  end

  def composition_section_text_info
    "**section.text**: #{check_section_element_completeness('section.text')}"
  end

  def check_section_element_completeness(path_expression)
    sections_count = resolve_path(composition_resource, path_expression).length
    selected_by_expression_count = resolve_path(composition_resource, path_expression).length

    boolean_to_humanized_string(sections_count == selected_by_expression_count)
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

  def composition_resource
    BundleDecorator.new(scratch_bundle).composition_resource
  end
end
