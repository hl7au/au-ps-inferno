# frozen_string_literal: true

module AUPSTestKit
  # A module to keep helper methods for attester tests
  module BasicTestAttesterModule
    def attester_party_resource
      return nil unless scratch_bundle.present?

      bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
      composition_resource = bundle_resource.composition_resource
      return nil unless composition_resource.present?

      attesters = composition_resource.respond_to?(:attester) ? composition_resource.attester : nil
      return nil if attesters.blank?

      attester_with_party = attesters.find do |a|
        party = a.respond_to?(:party) ? a.party : a['party']
        party.present?
      end
      return nil unless attester_with_party.present?

      party_ref = attester_with_party.respond_to?(:party) ? attester_with_party.party : attester_with_party['party']
      ref_str = party_ref.respond_to?(:reference) ? party_ref.reference : party_ref['reference']
      return nil if ref_str.blank?

      bundle_resource.resource_by_reference(ref_str)
    end

    def validate_attester_party_ms_elements(resource, elements_config)
      return unless resource.present? && elements_config.present?

      expressions = elements_config.map { |el| el['expression'] || el[:expression] }.compact
      mandatory = elements_config.select do |el|
        ((el['min'] || el[:min]) || 0).positive?
      end.map { |el| el['expression'] || el[:expression] }
      optional = elements_config.reject do |el|
        ((el['min'] || el[:min]) || 0).positive?
      end.map { |el| el['expression'] || el[:expression] }

      mandatory_populated = mandatory.all? { |path| resolve_path(resource, path).first.present? }
      optional_populated = optional.all? { |path| resolve_path(resource, path).first.present? }

      message_type = if !mandatory_populated
                       'error'
                     elsif !optional_populated
                       'warning'
                     else
                       'info'
                     end

      rtype_str = resource.respond_to?(:resourceType) ? resource.resourceType : resource['resourceType']
      profiles = resource_profiles(resource)
      profile_str = profiles.is_a?(Array) ? profiles.join(', ') : profiles.to_s
      header = "**Referenced attester.party**: #{rtype_str}#{" — #{profile_str}" if profile_str.present?}"

      list_lines = expressions.map do |expr|
        populated = resolve_path(resource, expr).first.present?
        "#{boolean_to_existent_string(populated)}: **#{expr}**"
      end
      add_message(message_type,
                  "Must Support elements correctly populated\n\n#{header}\n\n## List of Must Support elements populated or missing\n\n#{list_lines.join("\n\n")}")

      assert mandatory_populated, 'When any mandatory Must Support element is missing. See the list in messages tab.'
    end

    def validate_attester_party_ms_subelements(resource, parent_groups, resource_type_str, profile_str)
      return unless resource.present?

      header = "**Referenced attester.party**: #{resource_type_str}#{" — #{profile_str}" if profile_str.present?}"

      parent_groups.each do |group|
        parent_path = group[:parent]
        mandatory = group[:mandatory] || []
        optional = group[:optional] || []
        sub_elements = mandatory + optional

        parent_populated = resolve_path(resource, parent_path).first.present?

        unless parent_populated
          add_message('warning',
                      "Must support sub-elements correctly populated\n\n#{header}\n\n**Complex element #{parent_path}** is not populated. Must Support sub-elements that would be validated: #{sub_elements.join(', ')}.")
          next
        end

        message_types = sub_elements.map do |sub_element|
          sub_element_result = resolve_path(resource, sub_element).first.present?
          sub_element_mandatory = mandatory.include?(sub_element)
          if sub_element_result
            'info'
          else
            (sub_element_mandatory ? 'error' : 'warning')
          end
        end.uniq
        level = if message_types.include?('error')
                  'error'
                else
                  (message_types.include?('warning') ? 'warning' : 'info')
                end
        list_lines = sub_elements.map do |expr|
          populated = resolve_path(resource, expr).first.present?
          "#{boolean_to_existent_string(populated)}: **#{expr}**"
        end
        add_message(level,
                    "Must support sub-elements correctly populated\n\n#{header}\n\n## Complex element **#{parent_path}** — Must Support sub-elements populated or missing\n\n#{list_lines.join("\n\n")}")
      end

      mandatory_ok = parent_groups.all? do |g|
        next true unless resolve_path(resource, g[:parent]).first.present?

        (g[:mandatory] || []).all? { |el| resolve_path(resource, el).first.present? }
      end
      assert mandatory_ok,
             'When parent exists and any mandatory Must Support sub-element is missing. See the list in messages tab.'
    end

    def validate_attester_party_ms_identifier_slices(resource, slices, resource_type_str, profile_str)
      return unless resource.present? && slices.present?

      identifiers = identifiers_from_resource(resource) || []
      slice_results = slices.map do |slice|
        ident = find_identifier_by_system(identifiers, slice[:system])
        { slice: slice, identifier: ident }
      end

      header = "**Referenced attester.party**: #{resource_type_str}#{" — #{profile_str}" if profile_str.present?}"
      lines = slice_results.map do |r|
        if r[:identifier].present?
          type_str = identifier_type_display(r[:identifier])
          "✅ Populated: **#{r[:slice][:name]}** — system: #{r[:slice][:system]}#{type_str}"
        else
          "❌ Missing: **#{r[:slice][:name]}**"
        end
      end
      all_populated = slice_results.all? { |r| r[:identifier].present? }
      message_type = all_populated ? 'info' : 'warning'
      add_message(message_type,
                  "Must support identifier slices correctly populated\n\n#{header}\n\n## List of Must Support identifier slices populated or missing (type and system when populated)\n\n#{lines.join("\n\n")}")
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

    def test_composition_attester_party_ms_subelements
      check_bundle_exists_in_scratch
      resource = attester_party_resource
      skip_if resource.blank?, 'Attester or attester.party is not populated'

      attester_meta = composition_attester_metadata
      skip_if attester_meta.blank?, 'No attester metadata available'

      resource_type_str = resource_type(resource)
      parent_groups = author_ms_subelement_parent_groups(attester_meta, resource_type_str)
      skip_if parent_groups.blank?,
              'Referenced attester.party resource type has no complex elements with Must Support sub-elements'

      rtype_str, profile_str = author_resource_type_and_profiles(resource)
      validate_attester_party_ms_subelements(resource, parent_groups, rtype_str, profile_str)
    end

    def test_composition_attester_party_ms_identifier_slices
      check_bundle_exists_in_scratch
      resource = attester_party_resource
      skip_if resource.blank?, 'Attester or attester.party is not populated'

      resource_type_str = resource_type(resource)
      slices = AUTHOR_MS_IDENTIFIER_SLICES_BY_TYPE[resource_type_str] || []
      skip_if slices.blank?, 'Referenced attester.party resource type has no Must Support identifier slices'

      rtype_str, profile_str = author_resource_type_and_profiles(resource)
      validate_attester_party_ms_identifier_slices(resource, slices, rtype_str, profile_str)
    end

    def composition_attester_metadata
      data = load_metadata_yaml
      return [] unless data.present?

      data['attester'] || data[:attester] || []
    end
  end
end
