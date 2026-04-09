# frozen_string_literal: true

require_relative 'ms_elements_populated_helpers_module'

module AUPSTestKit
  # Must Support elements populated or missing message.
  module BasicTestMsElementsPopulatedModule
    include BasicTestMsElementsPopulatedHelpersModule

    def ms_elements_populated_message(container_type)
      guard_populated_resource(container_type)

      resource = get_resource_by_container_type(container_type)
      target_metadata = target_metadata_for_resource(container_type, resource)
      return unless target_metadata.present?

      state = default_population_state
      result_messages = base_result_messages(container_type, resource)

      process_elements(resource, target_metadata, state, result_messages)
      process_slices(resource, target_metadata, state, result_messages)

      finalize_population_result(state, result_messages)
    end
  end
end
