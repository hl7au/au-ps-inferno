# frozen_string_literal: true

module AUPSTestKit
  # Resolves the resource type from a resource. This module is used in tests for subject, author, custodian, attester.
  module BasicTestResolveResourceTypeModule
    def test_resource_type_is_valid?(container_type)
      result = raw_resource_type_is_valid(container_type)
      valid = result[:valid?]
      result_msg = result[:msg]

      build_message(valid, result_msg)
      assert valid, result_msg
    end

    def raw_resource_type_is_valid(container_type)
      resource = get_resource_by_container_type(container_type)
      return { valid?: false, msg: not_resolved_message(container_type) } if resource.blank?

      resolved_type = resource_type(resource)

      unless allowed_resource_types(container_type).include?(resolved_type)
        return { valid?: false, msg: invalid_resource_type_message(container_type, resolved_type) }
      end

      { valid?: true, msg: valid_resource_type_message(container_type, resolved_type) }
    end

    private

    def allowed_resource_types(container_type)
      container_metadata = get_target_metadata_by_container_type(container_type)
      container_metadata.map { |item| item[:resource_type] }
    end

    def build_message(valid, result_msg)
      msg_level = calculate_message_level(failed: !valid, warning: false, info: valid)
      add_message(msg_level, result_msg)
    end

    def not_resolved_message(container_type)
      "#{container_type.capitalize} reference does not resolve"
    end

    def invalid_resource_type_message(container_type, resource_type)
      "#{container_type.capitalize} reference resolves to a resource with invalid resource type: #{resource_type}"
    end

    def valid_resource_type_message(container_type, resource_type)
      "#{container_type.capitalize} reference resolves to a resource with valid resource type: #{resource_type}"
    end
  end
end
