# frozen_string_literal: true

module AUPSTestKit
  # Custodian Must Support sub-elements (warning/info only; no error level per spec).
  module BasicTestCustodianMsSubelements
    def validate_custodian_ms_subelements(resource, parent_groups, resource_type_str, profile_str)
      return unless resource.present?

      custodian_header = custodian_ms_subelements_header(resource_type_str, profile_str)
      parent_groups.each do |group|
        validate_custodian_ms_subelements_for_group(resource, group, custodian_header)
      end
    end

    private

    def custodian_ms_subelements_header(resource_type_str, profile_str)
      "**Referenced custodian**: #{resource_type_str}#{" — #{profile_str}" if profile_str.present?}"
    end

    def validate_custodian_ms_subelements_for_group(resource, group, custodian_header)
      parent_path = group[:parent]
      sub_elements = custodian_group_sub_elements(group)
      unless resolve_path(resource, parent_path).first.present?
        msg = custodian_subelement_parent_missing_message(custodian_header, parent_path, sub_elements)
        add_message('warning', msg)
        return
      end

      custodian_add_subelement_populated_message(resource, custodian_header, parent_path, sub_elements)
    end

    def custodian_group_sub_elements(group)
      (group[:mandatory] || []) + (group[:optional] || [])
    end

    def custodian_add_subelement_populated_message(resource, custodian_header, parent_path, sub_elements)
      all_populated = sub_elements.all? { |expr| resolve_path(resource, expr).first.present? }
      level = all_populated ? 'info' : 'warning'
      list_lines = custodian_subelement_list_lines(resource, sub_elements)
      body = custodian_subelement_populated_message(custodian_header, parent_path, list_lines)
      add_message(level, body)
    end

    def custodian_subelement_parent_missing_message(custodian_header, parent_path, sub_elements)
      detail = "**Complex element #{parent_path}** is not populated. " \
               "Must Support sub-elements that would be validated: #{sub_elements.join(', ')}."
      ['Must Support sub-elements correctly populated', custodian_header, detail].join("\n\n")
    end

    def custodian_subelement_list_lines(resource, sub_elements)
      sub_elements.map do |expr|
        populated = resolve_path(resource, expr).first.present?
        "#{boolean_to_existent_string(populated)}: **#{expr}**"
      end
    end

    def custodian_subelement_populated_message(custodian_header, parent_path, list_lines)
      heading = "## Complex element **#{parent_path}** — Must Support sub-elements populated or missing"
      ['Must Support sub-elements correctly populated', custodian_header, heading, list_lines.join("\n\n")].join("\n\n")
    end
  end
end
