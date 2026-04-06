# frozen_string_literal: true

module AUPSTestKit
  # Must Support sub-element validation for Composition attester.party reference (parent groups).
  module BasicTestAttesterMsSubelements
    def validate_attester_party_ms_subelements(resource, parent_groups, resource_type_str, profile_str)
      return unless resource.present?

      header = attester_party_referenced_type_profile_header(resource_type_str, profile_str)
      parent_groups.each do |group|
        process_attester_party_subelement_group(resource, group, header)
      end

      mandatory_ok = attester_party_mandatory_subelements_ok?(resource, parent_groups)
      assert mandatory_ok,
             'When parent exists and any mandatory Must Support sub-element is missing. See the list in messages tab.'
    end

    def test_composition_attester_party_ms_subelements
      check_bundle_exists_in_scratch
      resource = attester_party_resource
      skip_if resource.blank?, 'Attester or attester.party is not populated'
      attester_meta = composition_attester_metadata
      skip_if attester_meta.blank?, 'No attester metadata available'
      run_attester_party_subelements_validation(attester_meta, resource)
    end

    private

    def process_attester_party_subelement_group(resource, group, header)
      parent_path, mandatory, sub_elements = attester_party_subelement_group_fields(group)
      unless resolve_path_with_dar(resource, parent_path).first.present?
        warn_attester_party_subelement_parent_missing(header, parent_path, sub_elements)
        return
      end
      finalize_attester_party_subelement_group(resource, header, parent_path, sub_elements, mandatory)
    end

    def attester_party_subelement_group_fields(group)
      mandatory = group[:mandatory] || []
      optional = group[:optional] || []
      [group[:parent], mandatory, mandatory + optional]
    end

    def warn_attester_party_subelement_parent_missing(header, parent_path, sub_elements)
      add_message('warning', attester_party_subelement_parent_missing_message(header, parent_path, sub_elements))
    end

    def finalize_attester_party_subelement_group(resource, header, parent_path, sub_elements, mandatory)
      level = attester_party_subelement_message_level(resource, sub_elements, mandatory)
      list_lines = attester_party_ms_element_list_lines(resource, sub_elements)
      add_message(level, attester_party_subelement_populated_message(header, parent_path, list_lines))
    end

    def attester_party_subelement_parent_missing_message(header, parent_path, sub_elements)
      detail = "**Complex element #{parent_path}** is not populated. " \
               "Must Support sub-elements that would be validated: #{sub_elements.join(', ')}."
      [
        'Must support sub-elements correctly populated',
        '',
        header,
        '',
        detail
      ].join("\n\n")
    end

    def attester_party_subelement_message_level(resource, sub_elements, mandatory)
      message_types = attester_party_subelement_message_types(resource, sub_elements, mandatory)
      return 'error' if message_types.include?('error')

      message_types.include?('warning') ? 'warning' : 'info'
    end

    def attester_party_subelement_message_types(resource, sub_elements, mandatory)
      sub_elements.map do |sub_element|
        present = resolve_path_with_dar(resource, sub_element).first.present?
        next 'info' if present

        mandatory.include?(sub_element) ? 'error' : 'warning'
      end.uniq
    end

    def attester_party_subelement_populated_message(header, parent_path, list_lines)
      attester_party_join_message_sections(
        attester_party_subelement_populated_sections(header, parent_path, list_lines)
      )
    end

    def attester_party_subelement_populated_sections(header, parent_path, list_lines)
      [
        'Must support sub-elements correctly populated', '',
        header, '',
        attester_party_subelement_section_heading(parent_path), '',
        list_lines.join("\n\n")
      ]
    end

    def attester_party_subelement_section_heading(parent_path)
      "## Complex element **#{parent_path}** — " \
        'Must Support sub-elements populated or missing'
    end

    def attester_party_mandatory_subelements_ok?(resource, parent_groups)
      parent_groups.all? do |g|
        next true unless resolve_path_with_dar(resource, g[:parent]).first.present?

        (g[:mandatory] || []).all? { |el| resolve_path_with_dar(resource, el).first.present? }
      end
    end

    def run_attester_party_subelements_validation(attester_meta, resource)
      resource_type_str = resource_type(resource)
      parent_groups = author_ms_subelement_parent_groups(attester_meta, resource_type_str)
      skip_if parent_groups.blank?,
              'Referenced attester.party resource type has no complex elements with Must Support sub-elements'
      rtype_str, profile_str = author_resource_type_and_profiles(resource)
      validate_attester_party_ms_subelements(resource, parent_groups, rtype_str, profile_str)
    end
  end
end
