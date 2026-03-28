# frozen_string_literal: true

module AUPSTestKit
  # Author Must Support sub-elements (per parent group).
  module BasicTestAuthorMsSubelementsValidation
    def validate_author_ms_subelements(resource, parent_groups, resource_type_str, profile_str)
      return unless resource.present?

      author_header = "**Referenced author**: #{resource_type_str}#{" — #{profile_str}" if profile_str.present?}"
      parent_groups.each { |group| validate_author_ms_subelements_for_group(resource, group, author_header) }
      assert_author_ms_subelements_mandatory_ok(resource, parent_groups)
    end

    private

    def assert_author_ms_subelements_mandatory_ok(resource, parent_groups)
      mandatory_ok = parent_groups.all? do |group|
        next true unless resolve_path(resource, group[:parent]).first.present?

        (group[:mandatory] || []).all? { |el| resolve_path(resource, el).first.present? }
      end
      assert mandatory_ok,
             'When parent exists and any mandatory Must Support sub-element is missing. See the list in messages tab.'
    end

    def validate_author_ms_subelements_for_group(resource, group, author_header)
      parent_path = group[:parent]
      mandatory = group[:mandatory] || []
      sub_elements = mandatory + (group[:optional] || [])
      unless resolve_path(resource, parent_path).first.present?
        add_message('warning', author_subelement_parent_missing_message(author_header, parent_path, sub_elements))
        return
      end

      level = author_subelement_group_message_level(resource, sub_elements, mandatory)
      add_message(level, author_subelement_populated_message(author_header, parent_path, resource, sub_elements))
    end

    def author_subelement_parent_missing_message(author_header, parent_path, sub_elements)
      detail = "**Complex element #{parent_path}** is not populated. " \
               "Must Support sub-elements that would be validated: #{sub_elements.join(', ')}."
      ['Must Support sub-elements correctly populated', author_header, detail].join("\n\n")
    end

    def author_subelement_group_message_level(resource, sub_elements, mandatory)
      types = sub_elements.map do |sub_element|
        present = resolve_path(resource, sub_element).first.present?
        next 'info' if present

        mandatory.include?(sub_element) ? 'error' : 'warning'
      end.uniq
      return 'error' if types.include?('error')

      types.include?('warning') ? 'warning' : 'info'
    end

    def author_subelement_populated_message(author_header, parent_path, resource, sub_elements)
      heading = "## Complex element **#{parent_path}** — Must Support sub-elements populated or missing"
      lines = sub_elements.map do |expr|
        populated = resolve_path(resource, expr).first.present?
        "#{boolean_to_existent_string(populated)}: **#{expr}**"
      end
      ['Must Support sub-elements correctly populated', author_header, heading, lines.join("\n\n")].join("\n\n")
    end
  end
end
