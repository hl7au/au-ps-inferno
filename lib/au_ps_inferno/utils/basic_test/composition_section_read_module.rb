# frozen_string_literal: true

module AUPSTestKit
  # Reading composition section rows: profile/entry matching and list outcomes.
  module BasicTestCompositionSectionReadModule # rubocop:disable Metrics/ModuleLength
    private

    def read_composition_sections_info
      check_bundle_exists_in_scratch
      assert composition_sections_read_pass?, 'Some of the sections are not populated correctly.'
    end

    def composition_sections_read_pass?
      validation_errors = scratch[:validation_errors] || []
      bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
      composition_resource = bundle_resource.composition_resource
      is_passed = true
      metadata_manager.required_ms_sections_metadata.each do |section_metadata|
        is_passed &&= report_composition_section_read(section_metadata, composition_resource, bundle_resource,
                                                      validation_errors)
      end
      is_passed
    end

    def report_composition_section_read(section_metadata, composition_resource, bundle_resource, validation_errors)
      section_code = section_metadata[:code]
      section = composition_resource.section_by_code(section_code)
      issues = read_composition_section_issues(section_metadata, composition_resource, bundle_resource,
                                               validation_errors)
      text = composition_section_read_report_message(section_metadata, section, bundle_resource, section_code, issues)
      add_message(issues.empty? ? 'info' : 'error', text)
      issues.empty?
    end

    def composition_section_read_report_message(section_metadata, section, bundle_resource, section_code, issues)
      short = section_metadata[:short]
      header = short.present? ? "#{short} (#{section_code})" : section_code.to_s
      body = composition_section_read_list_body(section, bundle_resource, section_code)
      text = "#{header}\n\n#{body}"
      text += "\n\n#{issues.join("\n\n")}" if section.present? && issues.any?
      text
    end

    def composition_section_read_list_body(section, bundle_resource, section_code)
      return "No composition section found for code: #{section_code}" if section.blank?
      return empty_section_entry_reason_line(section) if section.entry_references.empty?

      section.entry_references.each_with_index.map do |ref, index|
        format_composition_section_entry_line(index, ref, bundle_resource)
      end.join("\n\n")
    end

    def format_composition_section_entry_line(index, ref, bundle_resource)
      resource = bundle_resource.resource_by_reference(ref)
      return "entry[#{index}]: #{ref} -> (resource not found)" if resource.blank?

      profiles = resource.meta&.profile || []
      suffix = profiles.any? ? "(meta.profile: #{profiles.join(', ')})" : '(no meta.profile)'
      "entry[#{index}]: #{ref} -> #{resource.resourceType} #{suffix}"
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

    def composition_section_ref_read_issues(ref, bundle_resource, entries_resource_types, validation_errors)
      resource = bundle_resource.resource_by_reference(ref)
      issues = []
      issues << "Resource not found for reference: #{ref}" if resource.blank?
      if resource.present? && !entries_resource_types.include?(resource.resourceType)
        issues << "Resource type: #{resource.resourceType} is not in the list " \
                  "of expected resource types: #{entries_resource_types}"
      end
      issues << "Validation error found for reference: #{ref}" if validation_errors.any? { |e| e[:full_url] == ref }
      issues
    end

    def permitted_resource_types(section_metadata)
      section_metadata[:entries].map do |entry|
        entry[:profiles].map do |profile|
          profile.split('|').first
        end
      end.flatten.uniq
    end

    def _read_composition_sections_info(sections_data, normalized_sections_data)
      check_bundle_exists_in_scratch
      composition = BundleDecorator.new(scratch_bundle.to_hash).composition_resource
      has_error = sections_data.any? do |section_data|
        read_composition_section_row_error?(section_data, composition, normalized_sections_data)
      end

      assert !has_error,
             'Some of the sections are not populated correctly. See the list of populated sections in messages tab.'
    end

    def read_composition_section_row_error?(section_data, composition, normalized_sections_data)
      section = composition.section_by_code(section_data[:code])
      return composition_section_missing?(section_data, normalized_sections_data) if section.blank?

      read_composition_section_present_row_error?(section_data, section)
    end

    def read_composition_section_present_row_error?(section_data, section)
      bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
      expected_constraints = expected_entry_constraints_from_section_entries(section_data)
      refs = section.entry_references
      mismatches = section_entries_mismatch_flags(bundle_resource, refs, expected_constraints)
      body = section_entry_list_or_empty_reason(section_data, section, nil)
      flags = composition_section_row_flags(section, refs, mismatches)
      read_composition_section_list_outcome?(section_data, body, flags)
    end

    def composition_section_row_flags(section, refs, mismatches)
      has_entries = refs.any?
      all_match = has_entries && !mismatches[:any_type_mismatch] && !mismatches[:any_profile_mismatch]

      {
        any_type_wrong: has_entries && mismatches[:any_type_mismatch],
        any_profile_wrong: has_entries && !mismatches[:any_type_mismatch] && mismatches[:any_profile_mismatch],
        empty_reason: section.empty_reason_str.present?,
        has_entries: has_entries,
        all_match: all_match
      }
    end

    def composition_section_missing?(section_data, normalized_sections_data)
      body = section_entry_list_or_empty_reason(section_data, nil, normalized_sections_data)
      add_message('error', "#{section_data[:short]} (#{section_data[:code]})\n\n#{body}")
      true
    end

    def expected_entry_constraints_from_section_entries(section_data)
      expected_resource_types, expected_profile_urls =
        collect_expected_types_and_profiles(section_data[:entries])

      {
        resource_types: expected_resource_types.uniq,
        profile_urls: expected_profile_urls.uniq
      }
    end

    def collect_expected_types_and_profiles(entries)
      entries.each_with_object([[], []]) do |entry, (resource_types, profile_urls)|
        (entry[:profiles] || []).each do |profile_data|
          add_type_and_profile(profile_data, resource_types, profile_urls)
        end
      end
    end

    def add_type_and_profile(profile_data, resource_types, profile_urls)
      resource_type, profile_url = profile_data.to_s.split('|', 2)
      resource_types << resource_type if resource_type.present?
      profile_urls << profile_url if profile_url.present?
    end

    def section_entries_mismatch_flags(bundle_resource, refs, expected_constraints)
      refs.each_with_object({ any_type_mismatch: false, any_profile_mismatch: false }) do |ref, flags|
        resource = bundle_resource.resource_by_reference(ref)
        if missing_or_wrong_type?(resource, expected_constraints)
          flags[:any_type_mismatch] = true
          next
        end
        next if resource_has_expected_profile?(resource, expected_constraints)

        flags[:any_profile_mismatch] = true
      end
    end

    def missing_or_wrong_type?(resource, expected_constraints)
      return true unless resource.present?

      !expected_constraints[:resource_types].include?(resource.resourceType)
    end

    def resource_has_expected_profile?(resource, expected_constraints)
      resource_profiles = resource.meta&.profile || []
      resource_profiles.any? { |profile| expected_constraints[:profile_urls].include?(profile) }
    end

    def read_composition_section_list_outcome?(section_data, body, flags)
      header = "#{section_data[:short]} (#{section_data[:code]})"
      composition_section_list_dispatch?(header, body, flags)
    end

    def composition_section_list_dispatch?(header, body, flags)
      return composition_section_list_on_error?(header, body) if flags[:any_type_wrong]
      return composition_section_list_on_profile_warning?(header, body) if flags[:any_profile_wrong]
      return composition_section_list_on_warning_empty?(header, body) if flags[:empty_reason] && !flags[:has_entries]
      return composition_section_list_on_info_ok?(header, body) if flags[:has_entries] && flags[:all_match]

      composition_section_list_on_no_entries_error?(header, body)
    end

    def composition_section_list_on_error?(header, body)
      add_message('error', "#{header}\n\n#{body}")
      true
    end

    def composition_section_list_on_warning_empty?(header, body)
      add_message('warning', "#{header}\n\n#{body}")
      false
    end

    def composition_section_list_on_profile_warning?(header, body)
      add_message('warning', "#{header}\n\n#{body}")
      false
    end

    def composition_section_list_on_info_ok?(header, body)
      add_message('info', "#{header}\n\n#{body}")
      false
    end

    def composition_section_list_on_no_entries_error?(header, body)
      add_message('error', "#{header} - section has no entries and no emptyReason\n\n#{body}")
      true
    end

    def section_entry_list_or_empty_reason(_section_data, section, _normalized_sections_data)
      return 'List of entry resources by type & profile: (section missing)' if section.blank?
      return empty_section_entry_reason_line(section) if section.entry_references.empty?

      bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
      section.entry_references.each_with_index.map do |ref, index|
        format_composition_section_entry_line(index, ref, bundle_resource)
      end.join("\n\n").to_s
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
