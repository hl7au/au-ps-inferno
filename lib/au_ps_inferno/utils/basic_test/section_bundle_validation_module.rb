# frozen_string_literal: true

module AUPSTestKit
  # Per-section bundle row validation (optional, mandatory, and mixed strictness).
  module BasicTestSectionBundleValidationModule
    private

    def validate_populated_undefined_sections_in_bundle(sections_code_to_filter, elements_array)
      skip_if scratch_bundle.blank?, 'No Bundle resource provided'

      bundle_resource = BundleDecorator.new(scratch_bundle)
      sections_to_validate = bundle_resource.composition_resource.section_codes.filter do |section_code|
        !sections_code_to_filter.include?(section_code)
      end

      skip_if sections_to_validate.blank?, 'No undefined sections to validate'
      validate_populated_sections_in_bundle(sections_to_validate, elements_array, optional: true)
    end

    def validate_populated_sections_in_bundle(section_codes_array, elements_array, optional: false)
      skip_if scratch_bundle.blank?, 'No Bundle resource provided'
      skip_if section_codes_array.blank?, 'No sections to validate'

      composition = BundleDecorator.new(scratch_bundle).composition_resource
      all_errors = section_codes_array.filter_map do |section_code|
        section_bundle_row_failure?(composition, section_code, elements_array, optional: optional)
      end

      assert all_errors.empty?, 'One or more sections are not correctly populated.'
    end

    def section_bundle_row_failure?(composition, section_code, elements_array, optional:)
      section = composition.section_by_code(section_code)
      return section_bundle_blank_outcome?(section_code, optional) if section.blank?

      section_bundle_ms_population_outcome?(section, section_code, elements_array)
    end

    def section_bundle_blank_outcome?(section_code, optional)
      add_message(optional ? 'warning' : 'error', "#{get_section_name(section_code)} is missing")
      optional ? false : true
    end

    def section_bundle_ms_population_outcome?(section, section_code, elements_array)
      body = section_ms_elements_message(section, section_code, elements_array)
      section_name = get_section_name(section_code)
      populated = all_paths_are_populated?(section, elements_array)
      heading = if populated
                  "All mandatory Must Support elements are correctly populated in the #{section_name} section"
                else
                  "At least one mandatory Must Support element is not populated in the #{section_name} section"
                end
      add_message(populated ? 'info' : 'error', "#{heading}\n\n#{body}")
      !populated
    end

    def section_ms_elements_message(section, section_code, elements_array)
      title = "### #{get_section_name(section_code)}"
      elements_list = elements_array.map do |element|
        "**#{element}**: #{boolean_to_existent_string(resolve_path_with_dar(section, element).first.present?)}"
      end.join("\n\n")
      [title, 'List of Must Support elements populated or missing:', elements_list].join("\n\n")
    end
  end
end
