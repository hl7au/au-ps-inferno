# frozen_string_literal: true

module AUPSTestKit
  # Per-section bundle row validation (optional, mandatory, and mixed strictness).
  module BasicTestSectionBundleValidationModule
    private

    def validate_populated_undefined_sections_in_bundle(sections_code_to_filter, elements_array)
      skip_if scratch_bundle.blank?, 'No Bundle resource provided'

      bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
      sections_to_validate = bundle_resource.composition_resource.section_codes.filter do |section_code|
        !sections_code_to_filter.include?(section_code)
      end

      skip_if sections_to_validate.blank?, 'No sections to validate'
      validate_populated_sections_in_bundle(sections_to_validate, elements_array, optional: true)
    end

    def validate_populated_sections_in_bundle(section_codes_array, elements_array, optional: false)
      skip_if scratch_bundle.blank?, 'No Bundle resource provided'
      skip_if section_codes_array.blank?, 'No sections to validate'

      composition = BundleDecorator.new(scratch_bundle.to_hash).composition_resource
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
      title = "### #{section.code_display_str}"
      elements_list = elements_array.map do |element|
        "**#{element}**: #{boolean_to_existent_string(resolve_path_with_dar(section, element).first.present?)}"
      end.join("\n\n")
      [title, 'List of Must Support elements populated or missing:', elements_list].join("\n\n")
    end

    def mixed_validate_populated_sections_in_bundle(section_codes_array, elements_array)
      skip_if scratch_bundle.blank?, 'No Bundle resource provided'
      skip_if section_codes_array.blank?, 'No sections to validate'

      composition = BundleDecorator.new(scratch_bundle.to_hash).composition_resource
      has_error = section_codes_array.any? do |section_code|
        mixed_section_bundle_row_error?(composition, section_code, elements_array)
      end

      assert !has_error,
             'Some of the sections are not populated. See the list of populated sections in messages tab.'
    end

    def mixed_section_bundle_row_error?(composition, section_code, elements_array)
      section = composition.section_by_code(section_code)
      return section_bundle_blank_outcome?(section_code, false) if section.blank?

      section_bundle_ms_population_outcome?(section, elements_array)
    end
  end
end
