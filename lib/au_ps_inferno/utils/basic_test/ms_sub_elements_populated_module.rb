# frozen_string_literal: true

require_relative 'ms_elements_populated_helpers_module'

module AUPSTestKit
  # Must Support elements populated or missing message.
  module BasicTestMsSubElementsPopulatedModule
    include BasicTestMsElementsPopulatedHelpersModule

    def ms_sub_elements_populated_message(container_type)
      guard_populated_resource(container_type)

      resource = get_resource_by_container_type(container_type)
      raw_metadata = metadata_manager.group_metadata_by_resource_type(resource.resourceType)
      return unless raw_metadata.present?

      author_and_device_resource?(container_type, resource)

      profile_metadata = InfernoSuiteGenerator::Generator::GroupMetadata.new(raw_metadata)
      ms_checker = InfernoSuiteGenerator::MSChecker.new(profile_metadata)
      results = ms_checker.elements_present_statuses([resource], all_present: false)
      filtered_results = results.filter { |result| sub_element?(result[:path]) }
      new_grouped_sub_elements = filtered_results.group_by { |result| result[:path].split('.').first }
      omit_if new_grouped_sub_elements.blank?, 'No complex element with Must Support sub-elements is defined'

      new_grouped_sub_elements.each do |parent_path, sub_elements|
        sub_element_message(ms_checker, sub_elements, resource, parent_path, results)
      end

      assert assert_result(filtered_results, new_grouped_sub_elements),
             'When any mandatory Must Support sub-element is missing. See the list in messages tab.'
    end

    private

    def assert_result(results, grouped_sub_elements)
      result = true

      grouped_sub_elements.each do |parent_path, sub_elements|
        mandatory_sub_elements = sub_elements.filter { |res| res[:mandatory] == true }
        next if mandatory_sub_elements.empty?

        mandatory_sub_elements_present = mandatory_sub_elements.all? { |res| res[:present] == true }

        parent_element = results.find { |res| res[:path] == parent_path }
        next if parent_element.nil?

        parent_present = parent_element[:present] == true

        result = false if !mandatory_sub_elements_present && parent_present
      end

      result
    end

    def sub_element_message(ms_checker, sub_elements, resource, parent_path, results)
      message_level = build_message_level(ms_checker, sub_elements, results)
      message = build_sub_element_message_content(ms_checker, sub_elements, resource, parent_path, results)
      add_message(message_level, message)
    end

    def build_message_level(ms_checker, sub_elements, results)
      return 'warning' if parent_element_is_not_populated?(sub_elements, results)

      ms_checker.calculate_elements_status_message_level(sub_elements)
    end

    def build_sub_element_message_content(ms_checker, sub_elements, resource, parent_path, results)
      [
        'Must Support sub-elements correctly populated',
        "**Referenced subject**: #{resource.resourceType}",
        "## Complex element **#{parent_path}** — Must Support sub-elements populated or missing",
        sub_element_statuses_texts(ms_checker, sub_elements, results, parent_path)
      ].join("\n\n")
    end

    def sub_element_statuses_texts(ms_checker, sub_elements, results, parent_path)
      if parent_element_is_not_populated?(sub_elements, results)
        return parent_element_is_not_populated_text(parent_path,
                                                    sub_elements)
      end

      ms_checker.element_statuses_texts(sub_elements).map do |text|
        text.gsub('|- ', '')
      end.join("\n\n")
    end

    def parent_element_is_not_populated?(sub_elements, results)
      results.any? { |result| result[:path] == sub_elements[0][:path] && result[:present] == false }
    end

    def parent_element_is_not_populated_text(parent_path, sub_elements)
      "**Complex element #{parent_path}** is not populated. " \
        "Must Support sub-elements that would be validated: #{sub_elements.map do |element|
          element[:path]
        end.join(', ')}."
    end

    def sub_element?(path)
      path.include?('.')
    end
  end
end
