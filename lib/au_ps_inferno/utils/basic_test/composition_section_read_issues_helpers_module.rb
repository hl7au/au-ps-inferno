# frozen_string_literal: true

module AUPSTestKit
  # Helpers for reading composition section issues.
  module BasicTestCompositionSectionReadIssuesHelpersModule
    private

    def read_composition_section_issues(section_metadata, composition_resource, bundle_resource)
      section_code = section_metadata[:code]
      section = composition_resource.section_by_code(section_code)
      return ["No composition section found for code: #{section_code}"] if section.blank?

      entries_resource_types = permitted_resource_types(section_metadata)
      section.entry_references.flat_map do |ref|
        composition_section_ref_read_issues(ref, bundle_resource, entries_resource_types)
      end
    end

    def composition_section_ref_read_issues(ref, bundle_resource, entries_resource_types)
      resource = bundle_resource.resource_by_reference(ref)
      issues = []
      issues << "Resource not found for reference: #{ref}" if resource.blank?
      if resource.present? && !entries_resource_types.include?(resource.resourceType)
        issues << "Resource type: #{resource.resourceType} is not in the list " \
                  "of expected resource types: #{entries_resource_types}"
      end
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
