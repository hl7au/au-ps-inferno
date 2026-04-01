# frozen_string_literal: true

require_relative 'ms_elements_populated_helpers_module'

module AUPSTestKit
  # Must Support elements populated or missing message.
  module BasicTestMsElementsPopulatedModule
    include BasicTestMsElementsPopulatedHelpersModule

    def ms_elements_populated_message(container_type)
      resource = get_resource_by_container_type(container_type)
      skip_if resource.blank?, "No #{container_type} resource found"

      target_metadata = target_metadata_for_resource(container_type, resource)
      return unless target_metadata.present?

      state = default_population_state
      result_messages = base_result_messages(container_type, resource)

      process_elements(resource, target_metadata, state, result_messages)
      process_slices(resource, target_metadata, state, result_messages)

      finalize_population_result(state, result_messages)
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

    def normalize_slices_from_metadata(metadata)
      # According to the business logic, we need to check only extension slices in tests 8.01, 9.01 ... 11.01
      extension_slices(metadata).map { |slice| normalize_slice(slice) }
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
