# frozen_string_literal: true

module AUPSTestKit
  # Composition Must Support sub-elements (grouped paths) and parent-group validation on arbitrary resources.
  module BasicTestCompositionSubelementsModule
    private

    def validate_populated_sub_elements_in_composition(mandatory_ms, optional_ms)
      composition_resource = composition_resource_from_scratch
      return false unless composition_resource.present?

      grouped_elements = (mandatory_ms + optional_ms).group_by { |element| element.split('.').first }
      run_composition_subelements_assertions(composition_resource, grouped_elements, mandatory_ms)
    end

    def composition_resource_from_scratch
      return nil unless scratch_bundle.present?

      BundleDecorator.new(scratch_bundle).composition_resource
    end

    def run_composition_subelements_assertions(composition_resource, grouped_elements, mandatory_ms)
      any_parent = composition_any_subelement_parent_populated?(composition_resource, grouped_elements)
      mandatory_ok = composition_mandatory_subelements_ok?(composition_resource, grouped_elements, mandatory_ms)

      # Error: when any mandatory Must Support sub-elements are missing (i.e. subject.reference and attester.mode).
      # Warning: when any optional Must Support sub-elements are missing (i.e. attester.time and attester.party)
      # Info: when all optional Must Support sub-elements are populated
      # One message for each complex element with Must Support sub-elements, i.e. subject and attester
      # Include list of Must Support sub-elements populated and missing.

      grouped_elements.each do |parent_path, sub_elements|
        add_composition_subelements_messages(composition_resource, parent_path, sub_elements, mandatory_ms)
      end

      skip_if !any_parent, 'No complex element with Must Support sub-elements is populated'
      msg = 'Some of the mandatory Must Support sub-elements are not populated. ' \
            'See the list of populated sub-elements in messages tab.'
      assert mandatory_ok, msg
    end

    def composition_any_subelement_parent_populated?(composition_resource, grouped_elements)
      grouped_elements.any? do |parent_path, _|
        resolve_path_with_dar(composition_resource, parent_path).first.present?
      end
    end

    def composition_mandatory_subelements_ok?(composition_resource, grouped_elements, mandatory_ms)
      grouped_elements.all? do |parent_path, sub_elements|
        next true unless resolve_path_with_dar(composition_resource, parent_path).first.present?

        (mandatory_ms & sub_elements).all? { |el| resolve_path_with_dar(composition_resource, el).first.present? }
      end
    end

    def add_composition_subelements_messages(composition_resource, parent_path, sub_elements, mandatory_ms)
      unless resolve_path_with_dar(composition_resource, parent_path).first.present?
        add_message('warning', composition_subelement_parent_unpopulated_message(parent_path, sub_elements))
        return
      end

      level = composition_subelements_worst_level(composition_resource, sub_elements, mandatory_ms)
      add_message(level, populated_paths_info(composition_resource, sub_elements, mandatory_array: mandatory_ms))
    end

    def composition_subelement_parent_unpopulated_message(parent_path, sub_elements)
      detail = "**Complex element #{parent_path}** is not populated. " \
               "Must Support sub-elements that would be validated: #{sub_elements.join(', ')}."
      ['Must Support sub-elements correctly populated', 'Composition', detail].join("\n\n")
    end

    def composition_subelements_worst_level(composition_resource, sub_elements, mandatory_ms)
      levels = sub_elements.map do |sub_element|
        present = resolve_path_with_dar(composition_resource, sub_element).first.present?
        next 'info' if present

        mandatory_ms.include?(sub_element) ? 'error' : 'warning'
      end
      return 'error' if levels.include?('error')

      levels.include?('warning') ? 'warning' : 'info'
    end
  end
end
