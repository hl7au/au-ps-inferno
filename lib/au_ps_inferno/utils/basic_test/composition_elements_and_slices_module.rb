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
      add_message(msg_type,
                  populated_paths_info(composition_resource, elements_array,
                                       mandatory_array: required ? elements_array : []))
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
      message_data = populated_paths_info(composition_resource, paths[:combined], mandatory_array: paths[:required])
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
