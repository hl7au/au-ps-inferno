# frozen_string_literal: true

module AUPSTestKit
  # Reading composition section rows: profile/entry matching and list outcomes.
  module BasicTestCompositionSectionReadModule
    private

    def read_composition_sections_info
      check_bundle_exists_in_scratch
      assert composition_sections_read_pass?, 'Some of the sections are not populated correctly.'
    end

    def composition_sections_read_pass?
      validation_errors = scratch[:validation_errors] || []
      bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
      composition_resource = bundle_resource.composition_resource
      section_results = metadata_manager.required_ms_sections_metadata.map do |section_metadata|
        report_composition_section_read?(section_metadata, composition_resource, bundle_resource, validation_errors)
      end
      section_results.all?
    end

    def report_composition_section_read?(section_metadata, composition_resource, bundle_resource, validation_errors)
      section_code = section_metadata[:code]
      section = composition_resource.section_by_code(section_code)
      issues = read_composition_section_issues(section_metadata, composition_resource, bundle_resource,
                                               validation_errors)
      text = composition_section_read_report_message(section_metadata, section, bundle_resource, section_code)
      add_message(issues.empty? ? 'info' : 'error', text)
      issues.empty?
    end

    def composition_section_read_report_message(section_metadata, section, bundle_resource, section_code)
      short = section_metadata[:short]
      header = short.present? ? "#{short} (#{section_code})" : section_code.to_s
      body = composition_section_read_list_body(section, bundle_resource, section_code, section_metadata)
      "#{header}\n\n#{body}"
    end

    def composition_section_read_list_body(section, bundle_resource, section_code, section_metadata)
      return "No composition section found for code: #{section_code}" if section.blank?
      return empty_section_entry_reason_line(section) if section.entry_references.empty?

      section.entry_references.each.map do |ref|
        format_composition_section_entry_line(ref, bundle_resource, section_metadata)
      end.join("\n\n")
    end

    def format_composition_section_entry_line(ref, bundle_resource, section_metadata)
      resource = bundle_resource.resource_by_reference(ref)
      index = get_section_entry_index(section_metadata, bundle_resource, ref)
      return composition_section_entry_line_unresolved(ref) if resource.blank?
      unless permitted_resource_types(section_metadata).include?(resource.resourceType)
        return composition_section_entry_line_bad_type(index, ref)
      end

      composition_section_entry_line_resolved(index, ref, resource)
    end

    def get_section_entry_index(section_metadata, bundle_resource, ref)
      section_code = section_metadata[:code]
      section = bundle_resource.composition_resource.section_by_code(section_code)
      return nil if section.blank?

      section.get_entry_index_by_reference(ref)
    end

    def composition_section_entry_line_unresolved(ref)
      "**#{ref}** -> ❌ Reference does not resolve"
    end

    def composition_section_entry_line_bad_type(index, ref)
      "entry[#{index}]: **#{ref}** -> ❌ Invalid resource type"
    end

    def composition_section_entry_line_resolved(index, ref, resource)
      # validation_errors = scratch[:validation_errors] || []
      # has_val_error = validation_errors.any? { |e| e[:full_url] == ref }
      profiles = resource.meta&.profile || []
      suffix = profiles.any? ? "(meta.profile: #{profiles.join(', ')})" : '(no meta.profile)'
      # tail = has_val_error ? "#{suffix} ❌ Validation error" : suffix
      "entry[#{index}]: **#{ref}** -> #{resource.resourceType} #{suffix}"
    end

    def read_composition_section_issues(section_metadata, composition_resource, bundle_resource, validation_errors)
      section_code = section_metadata[:code]
      section = composition_resource.section_by_code(section_code)
      return ["No composition section found for code: #{section_code}"] if section.blank?

      entries_resource_types = permitted_resource_types(section_metadata)
      section.entry_references.flat_map do |ref|
        composition_section_ref_read_issues(ref, bundle_resource, entries_resource_types, validation_errors)
      end
    end

    def composition_section_ref_read_issues(ref, bundle_resource, entries_resource_types, _validation_errors)
      resource = bundle_resource.resource_by_reference(ref)
      issues = []
      issues << "Resource not found for reference: #{ref}" if resource.blank?
      if resource.present? && !entries_resource_types.include?(resource.resourceType)
        issues << "Resource type: #{resource.resourceType} is not in the list " \
                  "of expected resource types: #{entries_resource_types}"
      end
      # issues << "Validation error found for reference: #{ref}" if validation_errors.any? { |e| e[:full_url] == ref }
      issues
    end

    def permitted_resource_types(section_metadata)
      section_metadata[:entries].map do |entry|
        entry[:profiles].map do |profile|
          profile.split('|').first
        end
      end.flatten.uniq
    end

    def empty_section_entry_reason_line(section)
      if section.empty_reason_str.present?
        "emptyReason: #{section.empty_reason_str}"
      else
        'No entries; no emptyReason.'
      end
    end
  end
end
