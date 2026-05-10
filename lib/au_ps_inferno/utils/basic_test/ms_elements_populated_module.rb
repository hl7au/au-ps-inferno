# frozen_string_literal: true

require_relative 'ms_elements_populated_helpers_module'

module AUPSTestKit
  # Must Support elements populated or missing message.
  module BasicTestMsElementsPopulatedModule
    include BasicTestMsElementsPopulatedHelpersModule

    def ms_elements_populated_message(container_type)
      guard_populated_resource(container_type)

      resource = get_resource_by_container_type(container_type)
      resource_metadata_raw = metadata_manager.group_metadata_by_resource_type(resource.resourceType)
      return unless resource_metadata_raw.present?

      profile_metadata = InfernoSuiteGenerator::Generator::GroupMetadata.new(resource_metadata_raw)

      author_and_device_resource?(container_type, resource)

      assert all_ms_mandatory_elements_populated?(resource, profile_metadata), assert_message
    end

    private

    def all_ms_mandatory_elements_populated?(resource, profile_metadata)
      ms_checker = InfernoSuiteGenerator::MSChecker.new(profile_metadata)
      ms_checks_results = elements(ms_checker, [resource])
      ms_slices_results = slices(ms_checker, [resource])
      ms_extension_results = extensions(ms_checker, [resource])
      all_check_results = [*ms_checks_results, *ms_slices_results, *ms_extension_results]

      status = ms_checker.calculate_elements_status_message_level(all_check_results)
      message = ms_checker.build_report_message(profile_metadata, all_check_results)
      add_message(status, message.join("\n\n"))

      all_check_results.none? { |result| !result[:present] && result[:mandatory] }
    end

    def elements(checker, resources)
      elements_statuses = checker.elements_present_statuses(resources, all_present: false)
      elements_statuses.filter { |result| element_simple?(result[:path]) }
    end

    def slices(checker, resources)
      slices_statuses = checker.slices_present_statuses(resources, all_present: false)
      slices_statuses.filter { |result| element_simple?(result[:path]) }
    end

    def extensions(checker, resources)
      ms_extension_results = checker.extensions_present_statuses(resources, all_present: false)
      normalized_ms_extension_results(ms_extension_results)
    end

    def normalized_ms_extension_results(ms_extension_results)
      ms_extension_results.map do |result|
        {
          definition: result[:definition],
          path: result[:definition][:id].split(':')[-1],
          present: result[:present],
          mandatory: false
        }
      end
    end

    def element_simple?(path)
      !path.include?('.')
    end
  end
end
