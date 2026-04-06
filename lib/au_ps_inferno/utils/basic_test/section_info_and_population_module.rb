# frozen_string_literal: true

module AUPSTestKit
  # Info reporting for section entries/MS elements and bundle-level section population checks.
  module BasicTestSectionInfoAndPopulationModule
    private

    def info_entry_resources_by_type_and_profile(sections_data, normalized_sections_data)
      title = '## List any entry resources by type & profile'
      result = []
      sections_data.each do |section_data|
        result.concat(info_entry_lines_for_section(section_data, normalized_sections_data))
      end
      info [title, result.join("\n\n")].join("\n\n")
    end

    def info_entry_lines_for_section(section_data, normalized_sections_data)
      valid_types = info_section_valid_resource_types(section_data)
      header = "### #{section_data[:short]} (#{section_data[:code]})"
      filtered = normalized_sections_data.find { |s| s['code'] == section_data[:code] }
      entity = SectionTestClass.new(filtered, scratch_bundle)
      ref_lines = info_entry_resource_ref_lines(entity, valid_types)
      [header, *ref_lines]
    end

    def info_entry_resource_ref_lines(entity, valid_types)
      (entity.references || []).filter_map do |ref|
        res = entity.get_resource_by_reference(ref)
        next unless res.present?

        profiles = res.meta&.profile || []
        ok = valid_types.include?(res.resourceType)
        " #{boolean_to_existent_string(ok)} **#{ref}**: #{res.resourceType} (#{profiles.join(', ')})"
      end
    end

    def info_section_valid_resource_types(section_data)
      section_data[:entries].map { |entry| entry[:profiles] }.flatten.map { |profile| profile.split('|').first }.uniq
    end

    def info_sections_ms_elements(sections_configs)
      bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
      composition_resource = bundle_resource.composition_resource
      main_title = '## List Must Support elements populated or missing'
      result = []
      sections_configs.each do |section_config|
        lines = info_section_ms_element_lines(composition_resource, section_config)
        result.concat(lines) if lines
      end
      info [main_title, result.join("\n\n")].join("\n\n")
    end

    def info_section_ms_element_lines(composition_resource, section_config)
      section_resource = composition_resource.section_by_code(section_config[:code])
      return nil unless section_resource.present?

      title = "### #{section_config[:short]}(#{section_config[:code]})"
      element_lines = section_config[:ms_elements].map do |element|
        present = resolve_path_with_dar(section_resource, element[:expression]).first.present?
        "**#{element[:expression]}**: #{boolean_to_existent_string(present)}"
      end
      [title, *element_lines]
    end

    def all_sections_present_in_bundle?(sections_array_codes, bundle)
      existing_section_codes = BundleDecorator.new(bundle.to_hash).composition_resource.section_codes
      sections_array_codes.all? { |section_code| existing_section_codes.include?(section_code) }
    end

    def all_mandatory_ms_elements_populated_in_sections?(sections_array_codes, bundle, mandatory_ms_elements)
      sections_array_codes.each do |section_code|
        section = BundleDecorator.new(bundle.to_hash).composition_resource.section_by_code(section_code)
        return false unless section.present?

        mandatory_ms_elements.map do |element|
          resolve_path_with_dar(section, element[:expression]).first.present?
        end.all?
      end
    end

    def profile_population_is_correct?(sections_data, bundle)
      sections_data.map do |section_data|
        section = BundleDecorator.new(bundle.to_hash).composition_resource.section_by_code(section_data[:code])
        return false unless section.present?

        section_data[:entries].map do |entry|
          entry[:profiles].map do |profile|
            profile_population_is_correct_for_section?(section, profile.split('|').first, bundle)
          end
        end.all?
      end.all?
    end

    def profile_population_is_correct_for_section?(section, resource_type, bundle)
      bundle_resource = BundleDecorator.new(bundle.to_hash)
      section.entry_references.map do |reference|
        resource = bundle_resource.resource_by_reference(reference)
        resource.resourceType == resource_type
      end.all?
    end

    def resource_by_ref_matches_profile?(ref, profile, bundle)
      resource = BundleDecorator.new(bundle.to_hash).resource_by_reference(ref)
      return false unless resource.present?

      resource.meta.profile.include?(profile)
    end
  end
end
