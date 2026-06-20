# frozen_string_literal: true

module AUPSTestKit
  # Composition Must Support elements and optional slices (e.g. event:careProvisioningEvent).
  module BasicTestCompositionElementsAndSlicesModule
    private

    def validate_populated_elements_in_composition(elements_array, required: true)
      composition_resource = composition_resource_from_scratch
      return false unless composition_resource.present?

      result = all_paths_are_populated?(composition_resource, elements_array)
      msg_type = composition_elements_message_type(result, required)
      list = populated_paths_info(composition_resource, elements_array,
                                  mandatory_array: required ? elements_array : [])
      add_message(msg_type, "#{composition_elements_message_heading(result, required)}\n\n#{list}")
      assert_composition_elements_if_required(result, required)
    end

    def composition_elements_message_type(result, required)
      return 'info' if result

      required ? 'error' : 'warning'
    end

    def composition_elements_message_heading(result, required)
      if required
        result ? all_mandatory_ms_populated_heading : mandatory_ms_missing_heading
      else
        result ? all_optional_ms_populated_heading : optional_ms_missing_heading
      end
    end

    def assert_composition_elements_if_required(result, required)
      return unless required

      assert result, 'Mandatory Must Support elements are not populated.'
    end

    SLICE_DISPLAY_NAME = 'event:careProvisioningEvent'

    def validate_populated_slices_in_composition(slices_array)
      return false unless scratch_bundle.present?

      composition_resource = BundleDecorator.new(scratch_bundle).composition_resource
      return false unless composition_resource.present?

      check_event_slice_presence(composition_resource, slices_array)
    end

    def check_event_slice_presence(composition_resource, slices_array)
      event = composition_resource.event_by_code('PCPR')

      if event.nil?
        add_message('warning',
                    "Must Support slice #{SLICE_DISPLAY_NAME} is not populated.\n\n#{ms_remediation('sliced element')}")
        return
      end

      mandatory_ok = slices_array.map do |slice|
        composition_slice_mandatory_ok?(composition_resource, slice)
      end.all?
      assert mandatory_ok, 'Must Support sliced element is not correctly populated.'
    end

    # Reports one status-specific message per slice and returns whether its mandatory sub-elements are populated.
    def composition_slice_mandatory_ok?(composition_resource, slice)
      paths = composition_slice_element_paths(slice)
      list = populated_paths_info(composition_resource, paths[:combined], mandatory_array: paths[:required])
      mandatory_ok = all_paths_are_populated?(composition_resource, paths[:required])
      optional_ok = all_paths_are_populated?(composition_resource, paths[:optional])

      level = composition_slice_level(mandatory_ok, optional_ok)
      heading = ms_status_heading(level, 'sliced element', SLICE_DISPLAY_NAME)
      add_message(level, "#{heading}\n\n#{list}\n\nSlice: **#{SLICE_DISPLAY_NAME}**")
      mandatory_ok
    end

    def composition_slice_level(mandatory_ok, optional_ok)
      return 'error' unless mandatory_ok
      return 'warning' unless optional_ok

      'info'
    end

    def composition_slice_element_paths(slice)
      base = slice[:path]
      required = slice[:mandatory_ms_sub_elements].map { |el| "#{base}.#{el}" }
      optional = slice[:optional_ms_sub_elements].map { |el| "#{base}.#{el}" }
      { required: required, optional: optional, combined: required + optional }
    end
  end
end
