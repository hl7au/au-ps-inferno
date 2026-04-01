# frozen_string_literal: true

require_relative '../basic_test_contants_module'

module AUPSTestKit
  # Patient (subject) Must Support primitives and optional extension slices.
  module BasicTestSubjectPatientMsElements
    include BasicTestConstants

    private

    def subject_ms_elements_evaluation(resource)
      mandatory_ok = all_paths_are_populated?(resource, SUBJECT_MANDATORY_MS_PRIMITIVES)
      optional_primitives_ok = all_paths_are_populated?(resource, SUBJECT_OPTIONAL_MS_PRIMITIVES)
      slice_messages, optional_slices_ok = subject_ms_optional_slice_results(resource)
      optional_ok = optional_primitives_ok && optional_slices_ok
      info_to_print = subject_ms_elements_info_to_print(resource, slice_messages)
      [mandatory_ok, optional_ok, info_to_print]
    end

    def subject_ms_elements_add_message_and_assert(resource, mandatory_ok, optional_ok, info_to_print)
      add_message(
        calculate_message_level(
          failed: !mandatory_ok,
          warning: mandatory_ok && !optional_ok,
          info: mandatory_ok && optional_ok
        ),
        ms_elements_populated_message(resource, info_to_print)
      )
      assert mandatory_ok, subject_ms_elements_mandatory_assert_message
    end

    def get_extension_url_by_slice_name(resource_type, slice_name)
      return nil if resource_type.blank? || slice_name.blank?

      SLICE_EXTENSIONS_BY_RESOURCE_TYPE[resource_type][slice_name]
    end

    def subject_ms_optional_slice_results(resource)
      messages = []
      ok = SUBJECT_OPTIONAL_MS_SLICES.map do |slice|
        extension_url = get_extension_url_by_slice_name(resource_type(resource), slice)
        result = get_extension_value_by_url(resource, extension_url).present?
        messages << "#{boolean_to_existent_string(result)}: **#{slice}**"
        result
      end.all?
      [messages, ok]
    end

    def subject_ms_elements_info_to_print(resource, slice_messages)
      primitives = SUBJECT_MANDATORY_MS_PRIMITIVES + SUBJECT_OPTIONAL_MS_PRIMITIVES
      raw_lines = populated_paths_info_raw(resource, primitives) + slice_messages
      mandatory_elements = subject_mandatory_elements(resource)
      raw_lines.map { |info| append_mandatory_tag(info, mandatory_elements) }
    end

    def subject_mandatory_elements(resource)
      metadata_manager.get_subject_mandatory_elements_by_resource_type(resource_type(resource))
    end

    def append_mandatory_tag(info, mandatory_elements)
      element = info.split(':').last.strip.delete('*')
      mandatory_elements.include?(element) ? "#{info} (Mandatory)" : info
    end

    def subject_ms_elements_mandatory_assert_message
      'Some of the mandatory Must Support elements are not populated. ' \
        'See the list of populated primitives in messages tab.'
    end
  end
end
