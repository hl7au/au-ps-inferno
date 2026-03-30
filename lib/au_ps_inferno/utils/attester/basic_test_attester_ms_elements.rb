# frozen_string_literal: true

module AUPSTestKit
  # Must Support element path validation for Composition attester.party reference.
  module BasicTestAttesterMsElements
    def validate_attester_party_ms_elements(resource, elements_config)
      return unless resource.present? && elements_config.present?

      expressions, mandatory, optional = attester_party_split_ms_elements_config(elements_config)
      mandatory_populated, optional_populated = attester_party_ms_paths_populated_pair(resource, mandatory, optional)
      message_type = attester_party_ms_elements_message_type(mandatory_populated, optional_populated)
      add_message(message_type, attester_party_ms_elements_composed_body(resource, expressions))

      assert mandatory_populated, 'When any mandatory Must Support element is missing. See the list in messages tab.'
    end

    def test_composition_attester_party_ms_elements
      check_bundle_exists_in_scratch
      resource = attester_party_resource
      skip_if resource.blank?, 'Attester or attester.party is not populated'

      attester_meta = composition_attester_metadata
      skip_if attester_meta.blank?, 'No attester metadata available'

      resource_type_str = resource_type(resource)
      elements_config = author_complex_ms_elements_for_type(attester_meta, resource_type_str)
      skip_if elements_config.blank?,
              "No complex Must Support elements defined for attester.party type #{resource_type_str}"

      validate_attester_party_ms_elements(resource, elements_config)
    end

    private

    def attester_party_split_ms_elements_config(elements_config)
      expressions = elements_config.map { |el| ms_config_element_expression(el) }.compact
      mandatory = attester_party_ms_config_mandatory_expressions(elements_config)
      optional = attester_party_ms_config_optional_expressions(elements_config)
      [expressions, mandatory, optional]
    end

    def ms_config_element_expression(elem)
      elem['expression'] || elem[:expression]
    end

    def ms_config_element_mandatory?(elem)
      ((elem['min'] || elem[:min]) || 0).positive?
    end

    def attester_party_ms_config_mandatory_expressions(elements_config)
      elements_config.select { |el| ms_config_element_mandatory?(el) }.map { |el| ms_config_element_expression(el) }
    end

    def attester_party_ms_config_optional_expressions(elements_config)
      elements_config.reject { |el| ms_config_element_mandatory?(el) }.map { |el| ms_config_element_expression(el) }
    end

    def attester_party_ms_paths_populated_pair(resource, mandatory, optional)
      mandatory_populated = mandatory.all? { |path| resolve_path_with_dar(resource, path).first.present? }
      optional_populated = optional.all? { |path| resolve_path_with_dar(resource, path).first.present? }
      [mandatory_populated, optional_populated]
    end

    def attester_party_ms_elements_composed_body(resource, expressions)
      attester_party_join_message_sections(attester_party_ms_elements_section_lines(resource, expressions))
    end

    def attester_party_ms_elements_section_lines(resource, expressions)
      attester_party_ms_elements_message_parts(
        attester_party_ms_elements_resource_header(resource),
        attester_party_ms_element_list_lines(resource, expressions)
      )
    end

    def attester_party_ms_elements_message_parts(header, list_lines)
      [
        'Must Support elements correctly populated',
        '',
        header,
        '',
        '## List of Must Support elements populated or missing',
        '',
        list_lines.join("\n\n")
      ]
    end

    def attester_party_ms_elements_message_type(mandatory_populated, optional_populated)
      return 'error' unless mandatory_populated
      return 'warning' unless optional_populated

      'info'
    end

    def attester_party_ms_elements_resource_header(resource)
      rtype_str = resource.respond_to?(:resourceType) ? resource.resourceType : resource['resourceType']
      profiles = resource_profiles(resource)
      profile_str = profiles.is_a?(Array) ? profiles.join(', ') : profiles.to_s
      "**Referenced attester.party**: #{rtype_str}#{" — #{profile_str}" if profile_str.present?}"
    end
  end
end
