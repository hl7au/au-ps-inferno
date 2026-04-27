# frozen_string_literal: true

module AUPSTestKit
  module BasicTestCompositionSectionReadModule
    # Composition Must Support elements in sections.
    module BasicTestCompositionSectionCheckResourcesMSElementsModule
      MANDATORY_ERROR_MS_MESSAGE = 'At least one mandatory Must Support elements is not populated.'
      OPTIONAL_MS_WARNING_MESSAGE = [
        'At least one optional Must Support element is not populated. ',
        'Further testing with data containing the missing elements or clarification ',
        'the system does not ever know a value for the element is required.'
      ].join.freeze
      MS_OKAY_MESSAGE = 'All Must Support elements are populated.'

      private

      def sections_profiles
        sections_profiles = metadata_manager.required_ms_sections_metadata.map do |section_metadata|
          section_metadata[:entries].map do |entry_metadata|
            entry_metadata[:profiles]
          end.flatten.uniq
        end.flatten.uniq

        sections_profiles.filter do |profile|
          profile.include?('au-ps')
        end
      end

      def resources_to_check_ms
        bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
        composition_resource = bundle_resource.composition_resource
        sections_codes = metadata_manager.required_ms_sections_metadata.map do |section_metadata|
          section_metadata[:code]
        end

        sections_codes.map do |section_code|
          composition_resource.section_by_code(section_code).entry_references.map do |ref|
            bundle_resource.resource_by_reference(ref)
          end
        end.flatten.uniq
      end

      def results_eror?(results)
        results.any? { |result| result == 'error' }
      end

      def results_warning?(results)
        results.any? { |result| result == 'warning' }
      end

      def optional_present?(element_status)
        element_status[:present] == false && element_status[:mandatory] == false
      end

      def mandatory_present?(element_status)
        element_status[:present] == false && element_status[:mandatory] == true
      end

      def status_hash(elements_statuses)
        failed_status = elements_statuses.any? do |element_status|
          mandatory_present?(element_status)
        end
        warning_status = elements_statuses.none? do |element_status|
          mandatory_present?(element_status)
        end && elements_statuses.any? do |element_status|
          optional_present?(element_status)
        end

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

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def process_profile(profile, resources_to_check_ms)
        resource_type = profile.split('|').first
        profile_url = profile.split('|').last
        profile_info_str = "**Profile:** #{resource_type} — #{profile_url}"
        filtered_resources = resources_to_check_ms.filter { |resource| resource.resourceType == resource_type }
        if filtered_resources.empty?
          full_message_data = [
            profile_info_str,
            '**Message:** No resources found'
          ]
          add_message('warning', full_message_data.join("\n\n"))
          return nil
        end

        elements_statuses = build_elements_statuses(resource_type, filtered_resources)
        full_message_data = [
          profile_info_str,
          "**Message:** #{message_with_details(elements_statuses)}",
          'List of Must Support elements populated or missing',
          build_elements_statuses_list(elements_statuses)
        ].flatten
        st_hash = status_hash(elements_statuses)
        msg_level = calculate_message_level(failed: st_hash[:failed], warning: st_hash[:warning], info: st_hash[:info])
        add_message(msg_level, full_message_data.join("\n\n"))
        msg_level
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      def build_elements_statuses(resource_type, filtered_resources)
        resource_metadata_raw = metadata_manager.group_metadata_by_resource_type(resource_type)
        resource_metadata = InfernoSuiteGenerator::Generator::GroupMetadata.new(resource_metadata_raw)
        MSChecker.new.elements_present_statuses(resource_metadata, filtered_resources)
      end

      def build_elements_statuses_list(elements_statuses)
        elements_statuses.map do |element_status|
          is_mandatory = element_status[:mandatory]
          missing_icon = is_mandatory ? '❌' : '⚠️'
          missing_text = "#{missing_icon} Missing"
          default_message = "#{element_status[:present] ? '✅ Populated' : missing_text}: #{element_status[:path]}"
          is_mandatory ? "#{default_message} (M)" : default_message
        end
      end

      def composition_section_check_ms_pass?
        results = check_resources_against_profiles(sections_profiles, resources_to_check_ms)
        return false if results_eror?(results)
        return true if results_warning?(results)

        add_message('info', 'All Must Support elements are populated.')
        true
      end
    end
  end
end
