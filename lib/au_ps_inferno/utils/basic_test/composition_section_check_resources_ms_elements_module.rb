# frozen_string_literal: true

module AUPSTestKit
  module BasicTestCompositionSectionReadModule
    # Composition Must Support elements in sections.
    # rubocop:disable Metrics/ModuleLength
    module BasicTestCompositionSectionCheckResourcesMSElementsModule
      MANDATORY_ERROR_MS_MESSAGE = 'At least one mandatory Must Support elements is not populated.'
      OPTIONAL_MS_WARNING_MESSAGE = [
        'At least one optional Must Support element is not populated. ',
        'Further testing with data containing the missing elements or clarification ',
        'the system does not ever know a value for the element is required.'
      ].join.freeze
      MS_OKAY_MESSAGE = 'All Must Support elements are populated.'
      LIST_MESSAGE = 'List of Must Support elements populated or missing'
      WARNING_ICON = '⚠️'
      ERROR_ICON = '❌'
      SUCCESS_ICON = '✅'

      private

      def raw_sections_profiles(sections_codes)
        sections_metadata = metadata_manager.sections_metadata_by_codes(sections_codes)
        sections_metadata.map do |section_metadata|
          section_metadata[:entries].map do |entry_metadata|
            entry_metadata[:profiles]
          end
        end.flatten.uniq
      end

      def sections_profiles(sections_codes)
        raw_sections_profiles(sections_codes).filter do |profile|
          profile.include?('au-ps')
        end
      end

      def resources_to_check_ms(sections_codes)
        bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
        composition_resource = bundle_resource.composition_resource

        entry_references = composition_resource.entry_references_by_codes(sections_codes)
        bundle_resource.resources_by_references(entry_references)
      end

      def result_has?(results, result_type)
        results.any? { |result| result == result_type }
      end

      def results_eror?(results)
        result_has?(results, 'error')
      end

      def results_warning?(results)
        result_has?(results, 'warning')
      end

      def element_status_has?(element_status, present, mandatory)
        element_status[:present] == present && element_status[:mandatory] == mandatory
      end

      def optional_present?(element_status)
        element_status_has?(element_status, false, false)
      end

      def mandatory_present?(element_status)
        element_status_has?(element_status, false, true)
      end

      def failed_status(elements_statuses)
        elements_statuses.any? do |element_status|
          mandatory_present?(element_status)
        end
      end

      def warning_status(elements_statuses)
        elements_statuses.none? do |element_status|
          mandatory_present?(element_status)
        end && elements_statuses.any? do |element_status|
          optional_present?(element_status)
        end
      end

      def status_hash(elements_statuses)
        failed_status = failed_status(elements_statuses)
        warning_status = warning_status(elements_statuses)

        { failed: failed_status, warning: warning_status, info: !failed_status && !warning_status }
      end

      def check_resources_against_profiles(sections_profiles, resources_to_check_ms)
        sections_profiles.map do |profile|
          process_profile(profile, resources_to_check_ms)
        end
      end

      def message_with_details(elements_statuses)
        status_hash = status_hash(elements_statuses)

        return MANDATORY_ERROR_MS_MESSAGE if status_hash[:failed] == true
        return OPTIONAL_MS_WARNING_MESSAGE if status_hash[:warning] == true

        MS_OKAY_MESSAGE
      end

      def msg_line(title, text)
        "**#{title}**: #{text}"
      end

      def normalize_resource_type_and_profile(profile)
        splitted_data = profile.split('|')
        raise StandardError, 'Profile is not in the correct format' if splitted_data.length != 2

        {
          resource_type: splitted_data[0],
          profile_url: splitted_data[1]
        }
      end

      def process_profile(profile, resources_to_check_ms)
        resource_type_and_profile = normalize_resource_type_and_profile(profile)
        resource_type, profile_url = resource_type_and_profile.values_at(:resource_type, :profile_url)
        profile_info_str = msg_line('Profile', "#{resource_type} — #{profile_url}")
        filtered_resources = resources_to_check_ms.filter { |resource| resource.resourceType == resource_type }
        return report_missing_resources(profile_info_str) if filtered_resources.empty?

        elements_statuses = build_elements_statuses(resource_type, filtered_resources)
        report_profile_elements_status(profile_info_str, elements_statuses)
      end

      def report_missing_resources(profile_info_str)
        full_message_data = [
          profile_info_str,
          msg_line('Message', 'No resources found')
        ]
        add_message('warning', full_message_data.join("\n\n"))
        nil
      end

      def report_profile_elements_status(profile_info_str, elements_statuses)
        full_message_data = [
          profile_info_str,
          msg_line('Message', message_with_details(elements_statuses)),
          LIST_MESSAGE,
          build_elements_statuses_list(elements_statuses)
        ].flatten

        msg_level = calculate_elements_status_message_level(elements_statuses)
        add_message(msg_level, full_message_data.join("\n\n"))
        msg_level
      end

      def calculate_elements_status_message_level(elements_statuses)
        st_hash = status_hash(elements_statuses)
        calculate_message_level(failed: st_hash[:failed], warning: st_hash[:warning], info: st_hash[:info])
      end

      def build_elements_statuses(resource_type, filtered_resources)
        resource_metadata_raw = metadata_manager.group_metadata_by_resource_type(resource_type)
        resource_metadata = InfernoSuiteGenerator::Generator::GroupMetadata.new(resource_metadata_raw)
        MSChecker.new.elements_present_statuses(resource_metadata, filtered_resources)
      end

      def build_elements_statuses_list(elements_statuses)
        elements_statuses.map do |element_status|
          build_element_status_text(element_status)
        end
      end

      def build_element_status_text(element_status)
        is_mandatory = element_status[:mandatory]
        missing_icon = is_mandatory ? ERROR_ICON : WARNING_ICON
        missing_text = "#{missing_icon} Missing"
        populated_text = "#{SUCCESS_ICON} Populated"
        element_status_text = element_status[:present] ? populated_text : missing_text
        default_message = "#{element_status_text}: #{element_status[:path]}"
        is_mandatory ? "#{default_message} (M)" : default_message
      end

      def composition_section_check_ms_pass?(sections_codes)
        results = check_resources_against_profiles(sections_profiles(sections_codes),
                                                   resources_to_check_ms(sections_codes))
        return false if results_eror?(results)
        return true if results_warning?(results)

        true
      end
    end
    # rubocop:enable Metrics/ModuleLength
  end
end
