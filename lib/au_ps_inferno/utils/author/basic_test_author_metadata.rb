# frozen_string_literal: true

module AUPSTestKit
  # Author entry metadata from ballot YAML and helpers to select MS elements by resource type.
  module BasicTestAuthorMetadata
    def composition_author_metadata
      data = load_metadata_yaml
      return [] unless data.present?

      data['author'] || data[:author] || []
    end

    def author_ms_subelement_parent_groups(author_metadata, resource_type)
      author_entry = author_metadata_entry_for_resource_type(author_metadata, resource_type)
      return [] unless author_entry.present?

      elements = author_entry['elements'] || author_entry[:elements] || []
      sub_elements = elements.filter { |elem| author_ms_metadata_element_is_subelement?(elem) }
      author_parent_groups_from_subelements(sub_elements)
    end

    private

    def author_parent_groups_from_subelements(sub_elements)
      return [] if sub_elements.empty?

      grouped = sub_elements.group_by { |elem| (elem['expression'] || elem[:expression]).to_s.split('.').first }
      grouped.map do |parent, els|
        mandatory, optional = author_ms_group_mandatory_optional_expressions(els)
        { parent: parent, mandatory: mandatory, optional: optional }
      end
    end

    def author_metadata_entry_for_resource_type(author_metadata, resource_type)
      author_metadata.find do |entry|
        (entry['resource_type'] || entry[:resource_type]).to_s == resource_type.to_s
      end
    end

    def author_ms_metadata_element_is_subelement?(elem)
      expr = (elem['expression'] || elem[:expression]).to_s
      id_str = (elem['id'] || elem[:id]).to_s
      expr.include?('.') && !id_str.include?(':')
    end

    def author_ms_element_min_positive?(element)
      ((element['min'] || element[:min]) || 0).positive?
    end

    def author_ms_group_mandatory_optional_expressions(elements)
      mandatory, optional = elements.partition { |elem| author_ms_element_min_positive?(elem) }
      [
        mandatory.map { |elem| elem['expression'] || elem[:expression] },
        optional.map { |elem| elem['expression'] || elem[:expression] }
      ]
    end
  end
end
