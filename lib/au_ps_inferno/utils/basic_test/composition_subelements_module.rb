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

      BundleDecorator.new(scratch_bundle.to_hash).composition_resource
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
        resolve_path(composition_resource, parent_path).first.present?
      end
    end

    def composition_mandatory_subelements_ok?(composition_resource, grouped_elements, mandatory_ms)
      grouped_elements.all? do |parent_path, sub_elements|
        next true unless resolve_path(composition_resource, parent_path).first.present?

        (mandatory_ms & sub_elements).all? { |el| resolve_path(composition_resource, el).first.present? }
      end
    end

    def add_composition_subelements_messages(composition_resource, parent_path, sub_elements, mandatory_ms)
      unless resolve_path(composition_resource, parent_path).first.present?
        add_message('warning', composition_subelement_parent_unpopulated_message(parent_path, sub_elements))
        return
      end

      level = composition_subelements_worst_level(composition_resource, sub_elements, mandatory_ms)
      add_message(level, populated_paths_info(composition_resource, sub_elements))
    end

    def composition_subelement_parent_unpopulated_message(parent_path, sub_elements)
      detail = "**Complex element #{parent_path}** is not populated. " \
               "Must Support sub-elements that would be validated: #{sub_elements.join(', ')}."
      ['Must Support sub-elements correctly populated', 'Composition', detail].join("\n\n")
    end

    def composition_subelements_worst_level(composition_resource, sub_elements, mandatory_ms)
      levels = sub_elements.map do |sub_element|
        present = resolve_path(composition_resource, sub_element).first.present?
        next 'info' if present

        mandatory_ms.include?(sub_element) ? 'error' : 'warning'
      end
      return 'error' if levels.include?('error')

      levels.include?('warning') ? 'warning' : 'info'
    end

    # Validates Must Support sub-elements only when the parent element is populated.
    # One message per complex element: error if any mandatory MS sub-element missing; warning if optional missing;
    # info when all present.
    # Pass: all messages are info or warning. Fail: any message is error.
    #
    # @param resource [Hash, FHIR::Model] The resource to validate (e.g. Patient)
    # @param parent_groups [Array<Hash>] Each hash has :parent (String), :mandatory (Array<String>),
    #   :optional (Array<String>)
    # @return [Boolean] false if resource blank or no parent populated; true when validation ran
    #   (assert handles pass/fail)
    def validate_populated_sub_elements_when_parent_populated(resource, parent_groups)
      return false unless resource.present?

      any_parent = parent_groups.any? { |group| resolve_path(resource, group[:parent]).first.present? }
      parent_groups.each { |group| add_parent_group_subelement_message(resource, group) }

      skip_if !any_parent, 'No complex element with Must Support sub-elements is populated'
      sub_msg = 'When a mandatory Must Support sub-element is missing but the parent exists. ' \
                'See the list in messages tab.'
      assert parent_groups_mandatory_subelements_ok?(resource, parent_groups), sub_msg
    end

    def add_parent_group_subelement_message(resource, group)
      return unless resolve_path(resource, group[:parent]).first.present?

      mandatory = group[:mandatory] || []
      optional = group[:optional] || []
      sub_elements = mandatory + optional
      message_type = parent_group_subelement_message_type(resource, sub_elements, mandatory)
      add_message(message_type, populated_paths_info(resource, sub_elements))
    end

    def parent_groups_mandatory_subelements_ok?(resource, parent_groups)
      parent_groups.all? do |group|
        next true unless resolve_path(resource, group[:parent]).first.present?

        (group[:mandatory] || []).all? { |el| resolve_path(resource, el).first.present? }
      end
    end

    def parent_group_subelement_message_type(resource, sub_elements, mandatory)
      types = sub_elements.map do |sub_element|
        present = resolve_path(resource, sub_element).first.present?
        next 'info' if present

        mandatory.include?(sub_element) ? 'error' : 'warning'
      end
      return 'error' if types.include?('error')

      types.include?('warning') ? 'warning' : 'info'
    end
  end
end
