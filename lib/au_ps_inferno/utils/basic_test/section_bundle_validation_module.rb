# frozen_string_literal: true

module AUPSTestKit
  # Per-section bundle row validation (optional, mandatory, and mixed strictness).
  module BasicTestSectionBundleValidationModule
    private

    def validate_populated_undefined_sections_in_bundle(sections_code_to_filter, elements_array)
      omit_unless_bundle_in_scratch

      bundle_resource = BundleDecorator.new(scratch_bundle)
      sections_to_validate = bundle_resource.composition_resource.section_codes.filter do |section_code|
        !sections_code_to_filter.include?(section_code)
      end

      skip_if sections_to_validate.blank?, 'No sections to validate'
      validate_populated_sections_in_bundle(sections_to_validate, elements_array, optional: true)
    end

    def validate_populated_sections_in_bundle(section_codes_array, elements_array, optional: false)
      omit_unless_bundle_in_scratch
      skip_if section_codes_array.blank?, 'No sections to validate'

      composition = BundleDecorator.new(scratch_bundle).composition_resource
      all_errors = section_codes_array.filter_map do |section_code|
        section_bundle_row_failure?(composition, section_code, elements_array, optional: optional)
      end

      assert all_errors.empty?,
             'Some of the sections are not populated. See the list of populated sections in messages tab.'
    end

    def section_bundle_row_failure?(composition, section_code, elements_array, optional:)
      section = composition.section_by_code(section_code)
      return section_bundle_blank_outcome?(section_code, optional) if section.blank?

      section_bundle_ms_population_outcome?(section, elements_array)
    end

    def section_bundle_blank_outcome?(section_code, optional)
      add_message(optional ? 'warning' : 'error', "#{get_section_name(section_code)} is missing")
      optional ? false : true
    end

    def section_bundle_ms_population_outcome?(section, elements_array)
      body = section_ms_elements_message(section, elements_array)
      return section_bundle_all_ms_ok?(body) if all_paths_are_populated?(section, elements_array)

      add_message('error', section_ms_missing_mandatory_message(body))
      true
    end

    def section_bundle_all_ms_ok?(body)
      add_message('info', "Section correctly populated\n\n#{body}")
      false
    end

    def section_ms_missing_mandatory_message(body)
      "For section with any mandatory Must Support element in section missing (i.e. title, code, text)\n\n#{body}"
    end

    def section_ms_elements_message(section, elements_array)
      [
        "### #{section.code_display_str}",
        'List of Must Support elements populated or missing:',
        section_ms_elements_list(section, elements_array),
        section_narrative_body(section)
      ].join("\n\n")
    end

    def section_ms_elements_list(section, elements_array)
      prefix = section_fhirpath_prefix(section)
      composition = composition_resource_from_scratch
      elements_array.map { |element| section_ms_element_line(composition, section, element, prefix) }.join("\n\n")
    end

    def section_ms_element_line(composition, section, element, prefix)
      status = boolean_to_existent_string(resolve_path_with_dar(section, element).first.present?)

      element_fhirpath_line(composition, prefix, element, status) || "#{status}: **#{element}**"
    end
  end
end
