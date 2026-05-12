# frozen_string_literal: true

require 'inferno_suite_generator/test_utils/ms_checker'

module AUPSTestKit
  # Composition Must Support elements and optional slices (e.g. event:careProvisioningEvent).
  module BasicTestCompositionElementsAndSlicesModule
    private

    def validate_mandatory_ms_elements_in_composition
      validate_composition_ms_elements_wrapper(mandatory: true)
    end

    def validate_optional_ms_elements_in_composition
      validate_composition_ms_elements_wrapper(mandatory: false)
    end

    def validate_composition_ms_elements_wrapper(mandatory: false)
      result = validate_composition_ms_elements(mandatory: mandatory)
      msg_level = result[:msg_level]

      add_message(msg_level, result[:msg])
      return unless mandatory == true

      assert msg_level == 'info',
             'Some of the elements are not populated. See the list of populated elements in messages tab.'
    end

    def validate_composition_ms_elements(mandatory: false)
      composition_resource = composition_resource_from_scratch
      return false unless composition_resource.present?

      raw_metadata = metadata_manager.group_metadata_by_resource_type('Composition')
      return nil unless raw_metadata.present?

      results, profile_metadata, ms_checker = raw_check_results(raw_metadata:, composition_resource:, mandatory:)

      {
        msg_level: ms_checker.calculate_elements_status_message_level(results),
        msg: ms_checker.build_report_message(profile_metadata, results).join("\n\n")
      }
    end

    def raw_check_results(raw_metadata:, composition_resource:, mandatory: false)
      profile_metadata = InfernoSuiteGenerator::Generator::GroupMetadata.new(raw_metadata)
      ms_checker = InfernoSuiteGenerator::MSChecker.new(profile_metadata)
      raw_results = ms_checker.elements_present_statuses([composition_resource], all_present: false)
      parent_results = raw_results.filter { |result| !result[:path].include?('.') }
      results = parent_results.filter { |result| result[:mandatory] == mandatory }

      [results, profile_metadata, ms_checker]
    end

    def validate_populated_elements_in_composition(elements_array, required: true)
      composition_resource = composition_resource_from_scratch
      return false unless composition_resource.present?

      result = all_paths_are_populated?(composition_resource, elements_array)
      msg_type = composition_elements_message_type(result, required)
      add_message(msg_type, populated_paths_info(composition_resource, elements_array))
      assert_composition_elements_if_required(result, required)
    end

    def composition_elements_message_type(result, required)
      return 'info' if result

      required ? 'error' : 'warning'
    end

    def assert_composition_elements_if_required(result, required)
      return unless required

      assert result,
             'Some of the elements are not populated. See the list of populated elements in messages tab.'
    end

    def validate_populated_slices_in_composition(slices_array)
      return false unless scratch_bundle.present?

      composition_resource = BundleDecorator.new(scratch_bundle).composition_resource
      return false unless composition_resource.present?

      check_event_slice_presence(composition_resource, slices_array)
    end

    def check_event_slice_presence(composition_resource, slices_array)
      event = composition_resource.event_by_code('PCPR')

      if event.nil?
        add_message('warning', 'event:careProvisioningEvent slice is not present')
        assert true
      else
        slices_array.all? do |slice|
          composition_slice_validation_passes?(composition_resource, slice, event)
        end
      end
    end

    def composition_slice_validation_passes?(composition_resource, slice, event)
      paths = composition_slice_element_paths(slice)
      message_data = populated_paths_info(composition_resource, paths[:combined])
      full_data = composition_slice_full_message_data(message_data)
      return false unless composition_slice_required_paths_ok?(composition_resource, paths, full_data)

      composition_slice_optional_and_event_outcome?(composition_resource, paths, full_data, message_data, event)
    end

    def composition_slice_full_message_data(message_data)
      "#{message_data}\n\nSlice: **event:careProvisioningEvent**"
    end

    def composition_slice_required_paths_ok?(composition_resource, paths, full_data)
      return true if all_paths_are_populated?(composition_resource, paths[:required])

      add_message('warning', full_data)
      false
    end

    def composition_slice_optional_and_event_outcome?(composition_resource, paths, full_data, message_data, event)
      unless all_paths_are_populated?(composition_resource, paths[:optional])
        add_message('warning', full_data)
        return true
      end
      return composition_slice_warn_if_event_nil?(message_data) if event.nil?

      add_message('info', full_data)
      true
    end

    def composition_slice_warn_if_event_nil?(message_data)
      add_message('warning', message_data)
      true
    end

    def composition_slice_element_paths(slice)
      base = slice[:path]
      required = slice[:mandatory_ms_sub_elements].map { |el| "#{base}.#{el}" }
      optional = slice[:optional_ms_sub_elements].map { |el| "#{base}.#{el}" }
      { required: required, optional: optional, combined: required + optional }
    end
  end
end
