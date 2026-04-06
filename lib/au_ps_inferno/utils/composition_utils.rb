# frozen_string_literal: true

require_relative 'bundle_decorator'
require_relative 'composition_utils/ms_elements'
require_relative 'composition_utils/boolean_and_stats'

# Utilities for FHIR Composition resources
module CompositionUtils
  include CompositionUtilsMsElements
  include CompositionUtilsBooleanAndStats

  def scratch_bundle
    scratch[:bundle_ips_resource]
  end

  def check_bundle_exists_in_scratch
    skip_if scratch_bundle.blank?, 'No Bundle resource provided'
  end

  def check_composition_section_code(section_code, composition_resource, sections_codes_mapping)
    section = composition_resource.section_by_code(section_code)
    return if section_is_nil?(section, section_code, sections_codes_mapping)

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

  def section_is_nil?(section, section_code, sections_codes_mapping)
    return false unless section.nil?

    warning "Section #{sections_codes_mapping[section_code]} (#{section_code}) not found in Composition resource"
    true
  end

  def section_references_are_empty?(section, section_code)
    return false unless section.present?

    section_references = section.entry_references
    return false unless section_references.empty?

    empty_reason_str = section.empty_reason_str
    if empty_reason_str.present?
      warning "Section #{section.code.coding.first.display}(#{section_code}) has no entries because #{empty_reason_str}"
    else
      warning "Section #{section.code.coding.first.display}(#{section_code}) has no entries"
    end
  end
end
