# frozen_string_literal: true

require_relative 'ms_elements_populated_helpers_module'

module AUPSTestKit
  # Must Support elements populated or missing message.
  module BasicTestMsSubElementsPopulatedModule
    include BasicTestMsElementsPopulatedHelpersModule

    def ms_sub_elements_populated_message(container_type)
      guard_populated_resource(container_type)

      resource = get_resource_by_container_type(container_type)
      target_metadata = target_metadata_for_resource(container_type, resource)
      return unless target_metadata.present?

      author_and_device_resource?(container_type, resource)

      state = default_population_state
      grouped_sub_elements = sub_elements_grouped_by_parent_path(target_metadata)
      omit_if grouped_sub_elements.blank?, 'No complex element with Must Support sub-elements is defined'

      add_sub_element_group_messages(container_type, resource, grouped_sub_elements, state)
      assert_sub_elements_mandatory_populated(state)
    end

    private

    def add_sub_element_group_messages(container_type, resource, grouped_sub_elements, state)
      grouped_sub_elements.each do |parent_path, sub_elements|
        result_messages = base_result_messages_sub_elements(container_type, resource, parent_path)
        group_result = process_sub_element_parent_group(resource, parent_path, sub_elements, state)
        result_messages.concat(group_result[:messages])
        add_message(group_result[:level], result_messages.join("\n\n"))
      end
    end

    def assert_sub_elements_mandatory_populated(state)
      assert mandatory_populated?(state),
             'When any mandatory Must Support sub-element is missing. See the list in messages tab.'
    end
  end
end
