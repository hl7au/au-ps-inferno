# frozen_string_literal: true

module AUPSTestKit
  # Internal helpers to keep the populated-message module concise.
  module BasicTestMsElementsPopulatedHelpersModule # rubocop:disable Metrics/ModuleLength
    private

    def target_metadata_for_resource(container_type, resource)
      metadata = get_target_metadata_by_container_type(container_type)
      return nil unless metadata.present?

      metadata.find { |item| item[:resource_type] == resource_type(resource) }
    end

    def default_population_state
      {
        mandatory_elements: true,
        mandatory_slices: true,
        optional_elements: true,
        optional_slices: true
      }
    end

    def base_result_messages(container_type, resource)
      [
        'Must Support elements correctly populated',
        "**Referenced #{container_type}**: #{resource_type_and_profile_str(resource, container_type)}",
        '## List of Must Support elements (complex) populated or missing'
      ]
    end

    def base_result_messages_sub_elements(container_type, resource, parent_path)
      [
        'Must Support sub-elements correctly populated',
        "**Referenced #{container_type}**: #{resource_type_and_profile_str(resource, container_type)}",
        "## Complex element **#{parent_path}** — Must Support sub-elements populated or missing"
      ]
    end

    def process_elements(resource, target_metadata, state, messages)
      normalize_elements_from_metadata(target_metadata).each do |element|
        min = element[:min]
        populated = resolve_path_with_dar(resource, element[:expression]).first.present?
        update_population_state(state, :element, populated, min)
        messages << element_message_item_template(populated, element[:label], mandatory?(min))
      end
    end

    def process_slices(resource, target_metadata, state, messages)
      normalize_slices_from_metadata(target_metadata).each do |slice|
        min = slice[:min]
        populated = resolve_slice_populated?(resource, slice)
        update_population_state(state, :slice, populated, min)
        messages << element_message_item_template(populated, slice[:label], mandatory?(min))
      end
    end

    def resolve_slice_populated?(resource, slice)
      # resolve_slice may return nil for unknown path; treat that as not populated.
      values = Array(resolve_slice(resource, slice[:expression], slice[:profile]))
      values.first.present?
    end

    def update_population_state(state, type, populated, min)
      return if populated

      if mandatory?(min)
        state[:"mandatory_#{type}s"] = false
      else
        state[:"optional_#{type}s"] = false
      end
    end

    def mandatory?(min)
      min.to_i.positive?
    end

    def finalize_population_result(state, messages)
      add_message(message_level(state), messages.join("\n\n"))
      assert mandatory_populated?(state), assert_message
    end

    def message_level(state)
      mandatory_ok = mandatory_populated?(state)
      optional_ok = optional_populated?(state)
      calculate_message_level(
        failed: !mandatory_ok,
        warning: mandatory_ok && !optional_ok,
        info: mandatory_ok && optional_ok
      )
    end

    def mandatory_populated?(state)
      state[:mandatory_elements] && state[:mandatory_slices]
    end

    def optional_populated?(state)
      state[:optional_elements] && state[:optional_slices]
    end

    def assert_message
      'When any mandatory Must Support element is missing. See the list in messages tab.'
    end

    def simple_elements(metadata)
      metadata[:elements].reject { |element| element[:expression].include?('.') }
    end

    def normalize_element(element)
      expression = element[:expression]
      {
        id: element[:id],
        expression: expression,
        min: element[:min],
        label: expression
      }
    end

    def extension_slices(metadata)
      metadata[:slices].filter { |slice| slice[:expression].include?('extension') }
    end

    def normalize_slice(slice)
      {
        id: slice[:id],
        expression: slice[:expression],
        profile: slice[:profile],
        min: slice[:min],
        label: slice[:label]
      }
    end

    def element_message_item_template(populated, label, mandatory)
      [
        "#{boolean_to_existent_string(populated)}:",
        "**#{label}**",
        mandatory ? '(M)' : nil
      ].compact.join(' ')
    end

    def normalize_elements_from_metadata(metadata)
      simple_elements(metadata).map { |element| normalize_element(element) }
    end

    def normalize_sub_elements_from_metadata(metadata)
      metadata[:elements]
        .filter { |element| element[:expression].include?('.') }
        .map do |element|
        normalize_element(element).merge(type: :element)
      end
    end

    def normalize_slices_from_metadata(metadata)
      # According to the business logic, we need to check only extension slices in tests 8.01, 9.01 ... 11.01
      extension_slices(metadata).map { |slice| normalize_slice(slice) }
    end

    def normalize_sub_elements_and_slices_from_metadata(metadata)
      normalize_sub_elements_from_metadata(metadata)
    end

    def sub_elements_grouped_by_parent_path(metadata)
      normalize_sub_elements_and_slices_from_metadata(metadata)
        .group_by { |item| item[:expression].to_s.split('.').first }
    end

    def parent_path_populated?(resource, parent_path)
      resolve_path_with_dar(resource, parent_path).first.present?
    end

    def sub_element_populated?(resource, sub_element)
      if sub_element[:type] == :slice
        resolve_slice_populated?(resource, sub_element)
      else
        resolve_path_with_dar(resource, sub_element[:expression]).first.present?
      end
    end

    def process_sub_element_parent_group(resource, parent_path, sub_elements, state)
      return missing_parent_group_result(parent_path, sub_elements) unless parent_path_populated?(resource, parent_path)

      populated_parent_group_result(resource, sub_elements, state)
    end

    def missing_parent_group_result(parent_path, sub_elements)
      {
        level: 'warning',
        messages: sub_element_parent_missing_message(parent_path, sub_elements)
      }
    end

    def populated_parent_group_result(resource, sub_elements, state)
      types = sub_element_message_types(resource, sub_elements, state)
      { level: group_message_level(types), messages: sub_elements_populated_message_items(resource, sub_elements) }
    end

    def sub_element_message_types(resource, sub_elements, state)
      sub_elements.map do |sub_element|
        min = sub_element[:min]
        populated = sub_element_populated?(resource, sub_element)
        update_population_state(state, sub_element[:type], populated, min)
        sub_element_message_type(populated, min)
      end
    end

    def sub_element_message_type(populated, min)
      return 'info' if populated

      mandatory?(min) ? 'error' : 'warning'
    end

    def sub_elements_populated_message_items(resource, sub_elements)
      sub_elements.map do |sub_element|
        populated = sub_element_populated?(resource, sub_element)
        element_message_item_template(populated, sub_element[:label], mandatory?(sub_element[:min]))
      end
    end

    def sub_element_parent_missing_message(parent_path, sub_elements)
      expected = sub_elements.map { |item| item[:label] }.join(', ')
      detail = "**Complex element #{parent_path}** is not populated. " \
               "Must Support sub-elements that would be validated: #{expected}."
      [detail]
    end

    def group_message_level(types)
      return 'error' if types.include?('error')
      return 'warning' if types.include?('warning')

      'info'
    end

    def get_target_metadata_by_container_type(container_type)
      case container_type
      when 'subject'
        metadata_manager.subject_metadata
      when 'author'
        metadata_manager.author_metadata
      when 'custodian'
        metadata_manager.custodian_metadata
      when 'attester'
        metadata_manager.attester_metadata
      end
    end

    def get_resource_by_container_type(container_type)
      case container_type
      when 'subject'
        subject_resource
      when 'author'
        author_resource
      when 'custodian'
        custodian_resource
      when 'attester'
        attester_party_resource
      end
    end
  end
end
