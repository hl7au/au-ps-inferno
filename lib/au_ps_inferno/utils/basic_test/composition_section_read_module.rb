# frozen_string_literal: true

require_relative '../inferno_suite_generator_compat'
require_relative 'composition_section_check_resources_ms_elements_module'
require_relative 'composition_section_read_issues_helpers_module'
module AUPSTestKit
  # Reading composition section rows: profile/entry matching and list outcomes.
  module BasicTestCompositionSectionReadModule
    MANDATORY_SECTIONS_CODES = %w[11450-4 48765-2 10160-0].freeze
    RECOMMENDED_SECTIONS_CODES = %w[11369-6 30954-2 47519-4 46264-8].freeze
    OPTIONAL_SECTIONS_CODES = %w[42348-3 104605-1 47420-5 11348-0 10162-6 81338-6 18776-5 29762-2 8716-3].freeze

    include BasicTestCompositionSectionCheckResourcesMSElementsModule
    include BasicTestCompositionSectionReadIssuesHelpersModule

    private

    def test_composition_mandatory_sections
      check_bundle_exists_in_scratch
      test_mandatory_sections(scratch_bundle)
    end

    def test_composition_recommended_sections
      check_bundle_exists_in_scratch
      test_recommended_sections(scratch_bundle)
    end

    def test_composition_optional_sections
      check_bundle_exists_in_scratch
      test_optional_sections(scratch_bundle)
    end

    def test_mandatory_sections(bundle_data)
      test_composition_sections_data(sections_codes: MANDATORY_SECTIONS_CODES, bundle_data: bundle_data)
    end

    def test_recommended_sections(bundle_data)
      test_composition_sections_data(sections_codes: RECOMMENDED_SECTIONS_CODES, bundle_data: bundle_data)
    end

    def test_optional_sections(bundle_data)
      test_composition_sections_data(sections_codes: OPTIONAL_SECTIONS_CODES, bundle_data: bundle_data)
    end

    def test_composition_sections_data(sections_codes:, bundle_data:)
      bundle_resource = BundleDecorator.new(bundle_data.to_hash)
      refs_test_pass = composition_sections_references_resolution_pass?(sections_codes: sections_codes,
                                                                        bundle_resource: bundle_resource)
      ms_test_pass = composition_section_check_ms_pass?(sections_codes: sections_codes,
                                                        bundle_resource: bundle_resource)

      assert refs_test_pass, 'Some of the sections are not populated correctly.'
      assert ms_test_pass, 'Some of the sections are not populated with the correct Must Support elements.'
    end

    def composition_sections_references_resolution_pass?(sections_codes:, bundle_resource:)
      composition_resource = bundle_resource.composition_resource
      sections_metadata = metadata_manager.sections_metadata_by_codes(sections_codes)
      sections_metadata.map do |section_metadata|
        composition_section_references_resolution_issues?(section_metadata, composition_resource, bundle_resource)
      end.all?
    end

    def composition_section_references_resolution_issues?(section_metadata, composition_resource, bundle_resource)
      section_code = section_metadata[:code]
      section = composition_resource.section_by_code(section_code)
      issues = read_composition_section_issues(section_metadata, bundle_resource)
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
      section = bundle_resource.composition_resource.section_by_code(section_metadata[:code])
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
      profiles = resource.meta&.profile || []
      suffix = profiles.any? ? "(meta.profile: #{profiles.join(', ')})" : '(no meta.profile)'
      "entry[#{index}]: **#{ref}** -> #{resource.resourceType} #{suffix}"
    end
  end
end
