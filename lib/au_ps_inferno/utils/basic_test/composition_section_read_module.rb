# frozen_string_literal: true

module AUPSTestKit
  # Reading composition section rows: profile/entry matching and list outcomes.
  module BasicTestCompositionSectionReadModule
    private

    def read_composition_sections_info(sections_data, normalized_sections_data)
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
      expected_resource_types = []
      expected_profile_urls = []

      section_data[:entries].each do |entry|
        (entry[:profiles] || []).each do |profile_data|
          resource_type, profile_url = profile_data.to_s.split('|', 2)
          expected_resource_types << resource_type if resource_type.present?
          expected_profile_urls << profile_url if profile_url.present?
        end
      end

      {
        resource_types: expected_resource_types.uniq,
        profile_urls: expected_profile_urls.uniq
      }
    end

    def section_entries_mismatch_flags(bundle_resource, refs, expected_constraints)
      refs.each_with_object({ any_type_mismatch: false, any_profile_mismatch: false }) do |ref, flags|
        resource = bundle_resource.resource_by_reference(ref)
        unless resource.present?
          flags[:any_type_mismatch] = true
          next
        end

        unless expected_constraints[:resource_types].include?(resource.resourceType)
          flags[:any_type_mismatch] = true
          next
        end

        resource_profiles = resource.meta&.profile || []
        next if resource_profiles.any? { |profile| expected_constraints[:profile_urls].include?(profile) }

        flags[:any_profile_mismatch] = true
      end
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
      lines = section.entry_references.map { |ref| section_entry_line_for_reference(bundle_resource, ref) }
      lines.join("\n\n").to_s
    end

    def empty_section_entry_reason_line(section)
      if section.empty_reason_str.present?
        "emptyReason: #{section.empty_reason_str}"
      else
        'No entries; no emptyReason.'
      end
    end

    def section_entry_line_for_reference(bundle_resource, ref)
      resource = bundle_resource.resource_by_reference(ref)
      if resource.present?
        profiles = (resource.meta&.profile || []).join(', ')
        "**#{ref}**: #{resource.resourceType} (#{profiles})"
      else
        "**#{ref}**: (resource not found)"
      end
    end
  end
end
