# frozen_string_literal: true

module AUPSTestKit
  # Author Must Support: flat elements and identifier slices.
  module BasicTestAuthorMsElementsAndSlices
    def validate_author_ms_elements(resource, author_config_elements)
      return unless resource.present? && author_config_elements.present?

      expressions, mandatory, optional = author_split_ms_config_elements(author_config_elements)
      mandatory_ok = author_add_author_ms_elements_messages(resource, expressions, mandatory, optional)
      assert mandatory_ok, 'When any mandatory Must Support element is missing. See the list in messages tab.'
    end

    def validate_author_ms_identifier_slices(resource, slices, resource_type_str, profile_str)
      return unless resource.present? && slices.present?

      author_header = author_identifier_slices_header(resource_type_str, profile_str)
      slice_results = author_identifier_slice_results(identifiers_from_resource(resource) || [], slices)
      author_post_identifier_slices_messages(author_header, slice_results)
    end

    private

    def author_ms_list_lines(resource, expressions)
      expressions.map do |expr|
        populated = resolve_path_with_dar(resource, expr).first.present?
        mandatory = metadata_manager.get_author_mandatory_elements_by_resource_type(
          resource_type(resource)
        ).include?(expr)
        "#{boolean_to_existent_string(populated)}: **#{expr}**#{mandatory ? ' (Mandatory)' : ' (Optional)'}"
      end
    end

    def author_add_author_ms_elements_messages(resource, expressions, mandatory, optional)
      mandatory_populated = mandatory.all? { |path| resolve_path_with_dar(resource, path).first.present? }
      optional_populated = optional.all? { |path| resolve_path_with_dar(resource, path).first.present? }
      add_message(author_ms_elements_message_type(mandatory_populated, optional_populated),
                  ms_elements_populated_message(resource, author_ms_list_lines(resource, expressions)))
      mandatory_populated
    end

    def author_split_ms_config_elements(elements_config)
      expressions = elements_config.filter_map { |cfg| author_ms_config_expression(cfg) }
      mandatory_cfg, optional_cfg = elements_config.partition { |cfg| author_ms_config_min_positive?(cfg) }
      [
        expressions,
        mandatory_cfg.filter_map { |cfg| author_ms_config_expression(cfg) },
        optional_cfg.filter_map { |cfg| author_ms_config_expression(cfg) }
      ]
    end

    def author_ms_config_expression(cfg)
      cfg['expression'] || cfg[:expression]
    end

    def author_ms_config_min_positive?(cfg)
      ((cfg['min'] || cfg[:min]) || 0).positive?
    end

    def author_identifier_slices_header(resource_type_str, profile_str)
      "**Referenced author**: #{resource_type_str}#{" — #{profile_str}" if profile_str.present?}"
    end

    def author_post_identifier_slices_messages(author_header, slice_results)
      lines = slice_results.map { |result| author_identifier_slice_line(result) }
      message_type = slice_results.all? { |r| r[:identifier].present? } ? 'info' : 'warning'
      add_message(message_type, author_identifier_slices_full_message(author_header, lines))
    end

    def author_ms_elements_message_type(mandatory_populated, optional_populated)
      return 'error' unless mandatory_populated
      return 'warning' unless optional_populated

      'info'
    end

    def author_identifier_slice_results(identifiers, slices)
      slices.map do |slice|
        ident = find_identifier_by_system(identifiers, slice[:system])
        { slice: slice, identifier: ident }
      end
    end

    def author_identifier_slice_line(result)
      if result[:identifier].present?
        type_str = identifier_type_display(result[:identifier])
        "✅ Populated: **#{result[:slice][:name]}** — system: #{result[:slice][:system]}#{type_str}"
      else
        "❌ Missing: **#{result[:slice][:name]}**"
      end
    end

    def author_identifier_slices_full_message(author_header, lines)
      heading = '## List of Must Support identifier slices populated or missing (type and system when populated)'
      parts = ['Must support identifier slices correctly populated', author_header, heading, lines.join("\n\n")]
      parts.join("\n\n")
    end
  end
end
