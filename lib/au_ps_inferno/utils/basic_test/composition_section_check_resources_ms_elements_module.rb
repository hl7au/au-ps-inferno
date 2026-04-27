# frozen_string_literal: true

module AUPSTestKit
  module BasicTestCompositionSectionReadModule
    # Composition Must Support elements in sections.
    module BasicTestCompositionSectionCheckResourcesMSElementsModule
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

      def check_resources_against_profiles(sections_profiles, resources_to_check_ms)
        sections_profiles.map do |profile|
          process_profile(profile, resources_to_check_ms)
        end
      end

      def normalize_resource_type_and_profile(profile)
        splitted_data = profile.split('|')
        raise StandardError, 'Profile is not in the correct format' if splitted_data.length != 2

        {
          resource_type: splitted_data[0],
          profile_url: splitted_data[1]
        }
      end

      def msg_line(title, text)
        "**#{title}**: #{text}"
      end

      def process_profile(profile, resources_to_check_ms)
        resource_type_and_profile = normalize_resource_type_and_profile(profile)
        resource_type, profile_url = resource_type_and_profile.values_at(:resource_type, :profile_url)
        profile_info_str = msg_line('Profile', "#{resource_type} — #{profile_url}")
        checker = MSChecker.new
        filtered_resources = resources_to_check_ms.filter { |resource| resource.resourceType == resource_type }
        return report_missing_resources(profile_info_str) if filtered_resources.empty?

        resource_metadata = group_metadata_for(resource_type)
        check_result = checker.report_profile_elements_status(resource_metadata, filtered_resources)
        add_message(check_result[:msg_level], check_result[:message])
        check_result[:msg_level]
      end

      def group_metadata_for(resource_type)
        resource_metadata_raw = metadata_manager.group_metadata_by_resource_type(resource_type)
        InfernoSuiteGenerator::Generator::GroupMetadata.new(resource_metadata_raw)
      end

      def report_missing_resources(profile_info_str)
        full_message_data = [
          profile_info_str,
          msg_line('Message', 'No resources found')
        ]
        add_message('warning', full_message_data.join("\n\n"))
        nil
      end

      def composition_section_check_ms_pass?(sections_codes)
        results = check_resources_against_profiles(sections_profiles(sections_codes),
                                                   resources_to_check_ms(sections_codes))
        return false if results_eror?(results)
        return true if results_warning?(results)

        true
      end
    end
  end
end
