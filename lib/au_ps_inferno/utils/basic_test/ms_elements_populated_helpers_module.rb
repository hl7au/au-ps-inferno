# frozen_string_literal: true

module AUPSTestKit
  # Internal helpers to keep the populated-message module concise.
  module BasicTestMsElementsPopulatedHelpersModule
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

    def process_elements(resource, target_metadata, state, messages)
      normalize_elements_from_metadata(target_metadata).each do |element|
        populated = resolve_path_with_dar(resource, element[:expression]).first.present?
        update_population_state(state, :element, populated, element[:min])
        messages << element_message_item_template(populated, element[:label], mandatory?(element[:min]))
      end
    end

    def process_slices(resource, target_metadata, state, messages)
      normalize_slices_from_metadata(target_metadata).each do |slice|
        populated = resolve_slice_populated?(resource, slice)
        update_population_state(state, :slice, populated, slice[:min])
        messages << element_message_item_template(populated, slice[:label], mandatory?(slice[:min]))
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
      calculate_message_level(
        failed: !mandatory_populated?(state),
        warning: mandatory_populated?(state) && !optional_populated?(state),
        info: mandatory_populated?(state) && optional_populated?(state)
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
      {
        id: element[:id],
        expression: element[:expression],
        min: element[:min],
        label: element[:expression]
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
  end
end
