# frozen_string_literal: true

module AUPSTestKit
  # Custodian Must Support flat (complex) elements.
  module BasicTestCustodianMsElements
    def validate_custodian_ms_elements(resource, elements_config)
      return unless resource.present? && elements_config.present?

      expressions, mandatory, optional = custodian_split_ms_config_elements(elements_config)
      mandatory_ok = custodian_add_ms_elements_messages(resource, expressions, mandatory, optional)
      assert mandatory_ok,
             'When mandatory Must Support element is missing (e.g. name). See the list in messages tab.'
    end

    private

    def custodian_add_ms_elements_messages(resource, expressions, mandatory, optional)
      mandatory_populated = mandatory.all? { |path| resolve_path_with_dar(resource, path).first.present? }
      optional_populated = optional.all? { |path| resolve_path_with_dar(resource, path).first.present? }
      list_lines = custodian_ms_list_lines(resource, expressions)
      add_message(
        custodian_ms_elements_message_level(mandatory_populated, optional_populated),
        ms_elements_populated_message(resource, list_lines)
      )
      mandatory_populated
    end

    def custodian_ms_elements_message_level(mandatory_populated, optional_populated)
      calculate_message_level(
        failed: !mandatory_populated,
        warning: mandatory_populated && !optional_populated,
        info: mandatory_populated && optional_populated
      )
    end

    def custodian_split_ms_config_elements(elements_config)
      expressions = elements_config.filter_map { |cfg| custodian_ms_config_expression(cfg) }
      mandatory_cfg, optional_cfg = elements_config.partition { |cfg| custodian_ms_config_min_positive?(cfg) }
      [
        expressions,
        mandatory_cfg.filter_map { |cfg| custodian_ms_config_expression(cfg) },
        optional_cfg.filter_map { |cfg| custodian_ms_config_expression(cfg) }
      ]
    end

    def custodian_ms_config_expression(cfg)
      cfg['expression'] || cfg[:expression]
    end

    def custodian_ms_config_min_positive?(cfg)
      ((cfg['min'] || cfg[:min]) || 0).positive?
    end

    def custodian_ms_list_lines(resource, expressions)
      expressions.map do |expr|
        populated = resolve_path_with_dar(resource, expr).first.present?
        "#{boolean_to_existent_string(populated)}: **#{expr}**"
      end
    end
  end
end
