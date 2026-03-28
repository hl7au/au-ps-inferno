# frozen_string_literal: true

module AUPSTestKit
  # Custodian entry metadata from ballot YAML and helpers for MS elements.
  module BasicTestCustodianMetadata
    def composition_custodian_metadata
      data = load_metadata_yaml
      return nil unless data.present?

      data['custodian'] || data[:custodian]
    end

    def custodian_complex_ms_elements(custodian_meta)
      return [] unless custodian_meta.present?

      elements = custodian_meta['elements'] || custodian_meta[:elements] || []
      elements.filter { |elem| custodian_ms_metadata_element_is_complex_flat?(elem) }
    end

    def custodian_ms_subelement_parent_groups(custodian_meta)
      return [] unless custodian_meta.present?

      elements = custodian_meta['elements'] || custodian_meta[:elements] || []
      sub_elements = elements.filter { |elem| custodian_ms_metadata_element_is_subelement?(elem) }
      custodian_parent_groups_from_subelements(sub_elements)
    end

    private

    def custodian_parent_groups_from_subelements(sub_elements)
      return [] if sub_elements.empty?

      grouped = sub_elements.group_by { |elem| (elem['expression'] || elem[:expression]).to_s.split('.').first }
      grouped.map do |parent, els|
        mandatory, optional = custodian_ms_group_mandatory_optional_expressions(els)
        { parent: parent, mandatory: mandatory, optional: optional }
      end
    end

    def custodian_ms_metadata_element_is_complex_flat?(elem)
      expr = (elem['expression'] || elem[:expression]).to_s
      id_str = (elem['id'] || elem[:id]).to_s
      !expr.include?('.') && !id_str.include?(':')
    end

    def custodian_ms_metadata_element_is_subelement?(elem)
      expr = (elem['expression'] || elem[:expression]).to_s
      id_str = (elem['id'] || elem[:id]).to_s
      expr.include?('.') && !id_str.include?(':')
    end

    def custodian_ms_element_min_positive?(element)
      ((element['min'] || element[:min]) || 0).positive?
    end

    def custodian_ms_group_mandatory_optional_expressions(elements)
      mandatory, optional = elements.partition { |elem| custodian_ms_element_min_positive?(elem) }
      [
        mandatory.map { |elem| elem['expression'] || elem[:expression] },
        optional.map { |elem| elem['expression'] || elem[:expression] }
      ]
    end
  end
end
