# frozen_string_literal: true

module AUPSTestKit
  # Must Support elements populated or missing message.
  module BasicTestMsElementsPopulatedModule
    def ms_elements_populated_message(container_type)
      # Container type: subject, author, custodian, attester
      all_mandatory_elements_populated = true
      all_mandatory_slices_populated = true
      all_optional_elements_populated = true
      all_optional_slices_populated = true

      # Get the resource by container type
      resource = get_resource_by_container_type(container_type)
      skip_if resource.blank?, "No #{container_type} resource found"

      result_messages = [
        'Must Support elements correctly populated',
        "**Referenced #{container_type}**: #{resource_type_and_profile_str(resource, container_type)}",
        '## List of Must Support elements (complex) populated or missing'
      ]

      target_metadata = get_target_metadata_by_container_type(container_type)
      return unless target_metadata.present?

      filtered_target_metadata = target_metadata.find { |item| item[:resource_type] == resource_type(resource) }
      return unless filtered_target_metadata.present?

      # Get a list of normalized elements from the target metadata
      elements = normalize_elements_from_metadata(filtered_target_metadata)
      # Get a list of normalized slices from the target metadata
      slices = normalize_slices_from_metadata(filtered_target_metadata)
      # Check that all elements are populated
      elements.each do |element|
        result = resolve_path_with_dar(resource, element[:expression]).first.present?
        all_mandatory_elements_populated = false if !result && element[:min].to_i.positive?
        all_optional_elements_populated = false if !result && element[:min].to_i.zero?
        result_messages << element_message_item_template(result, element[:label], element[:min].to_i.positive?)
      end
      # Check that all slices are populated (Implement function for this to check slices (extensions, identifiers))
      slices.each do |slice|
        # resolve_slice may return nil for unknown path; treat that as not populated.
        slice_values = Array(resolve_slice(resource, slice[:expression], slice[:profile]))
        result = slice_values.first.present?
        all_mandatory_slices_populated = false if !result && slice[:min].to_i.positive?
        all_optional_slices_populated = false if !result && slice[:min].to_i.zero?
        result_messages << element_message_item_template(result, slice[:label], slice[:min].to_i.positive?)
      end

      result_messages = result_messages.join("\n\n")
      message_level = calculate_message_level(
        failed: !all_mandatory_elements_populated || !all_mandatory_slices_populated,
        warning: all_mandatory_elements_populated && all_mandatory_slices_populated && !all_optional_elements_populated && !all_optional_slices_populated,
        info: all_mandatory_elements_populated && all_mandatory_slices_populated && all_optional_elements_populated && all_optional_slices_populated
      )
      add_message(message_level, result_messages)

      test_result = all_mandatory_elements_populated && all_mandatory_slices_populated
      assert test_result, 'When any mandatory Must Support element is missing. See the list in messages tab.'
    end

    def element_message_item_template(populated, label, mandatory)
      [
        "#{boolean_to_existent_string(populated)}:",
        "**#{label}**",
        mandatory ? '(M)' : nil
      ].compact.join(' ')
    end

    def normalize_elements_from_metadata(metadata)
      filtered_elements = metadata[:elements].reject do |element|
        element[:expression].include?('.')
      end
      filtered_elements.map do |element|
        {
          id: element[:id],
          expression: element[:expression],
          min: element[:min],
          label: element[:expression]
        }
      end
    end

    def normalize_slices_from_metadata(metadata)
      # According to the business logic, we need to check only extension slices in tests 8.01, 9.01 ... 11.01
      filtered_slices = metadata[:slices].filter do |slice|
        slice[:expression].include?('extension')
      end
      filtered_slices.map do |slice|
        {
          id: slice[:id],
          expression: slice[:expression],
          profile: slice[:profile],
          min: slice[:min],
          label: slice[:label]
        }
      end
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
