# frozen_string_literal: true

require_relative '../inferno_suite_generator_compat'
require 'inferno_suite_generator/test_utils/ms_checker'
module AUPSTestKit
  module BasicTestCompositionSectionReadModule
    # Composition Must Support elements in sections.
    module BasicTestCompositionSectionCheckResourcesMSElementsModule # rubocop:disable Metrics/ModuleLength
      AU_PS_PROFILE_BASE_URL = 'http://hl7.org.au/fhir/ps/StructureDefinition/'

      def check_ms_elements_populated(resource_type, resources)
        profile_metadata = group_metadata_for(resource_type)
        ms_checker_for(profile_metadata).elements_present_statuses(resources)
      end

      private

      def raw_sections_profiles(sections_codes)
        sections_metadata = metadata_manager.sections_metadata_by_codes(sections_codes)
        sections_metadata.flat_map do |section_metadata|
          section_short = section_metadata[:short]
          section_code = section_metadata[:code]
          section_metadata[:entries].flat_map do |entry_metadata|
            entry_metadata[:profiles].map do |profile|
              {
                profile: profile,
                section_short: section_short,
                section_code: section_code
              }
            end
          end
        end
      end

      def sections_profiles(sections_codes)
        uniq_profiles = Set.new
        raw_sections_profiles(sections_codes).filter do |profile|
          _, profile_url = profile[:profile].split('|', 2)
          next false if uniq_profiles.include?(profile_url)
          next false unless profile_url.present? && profile_url.start_with?(AU_PS_PROFILE_BASE_URL)
          next false if uniq_profiles.include?(profile_url)

          uniq_profiles.add(profile_url)
          true
        end
      end

      def resources_to_check_ms(sections_codes:, bundle_resource:)
        composition_resource = bundle_resource.composition_resource

        entry_references = composition_resource.entry_references_by_codes(sections_codes)
        bundle_resource.resources_by_references(entry_references)
      end

      def result_has?(results, result_type)
        results.any? { |result| result == result_type }
      end

      def results_error?(results)
        result_has?(results, 'error')
      end

      def results_warning?(results)
        result_has?(results, 'warning')
      end

      def check_ms_elements_populated_against_profiles(sections_profiles, resources_to_check_ms)
        sections_profiles.map { |profile| process_profile(profile, resources_to_check_ms) }
      end

      def normalize_resource_type_and_profile(profile)
        parts = profile.split('|')
        raise StandardError, 'Profile is not in the correct format' if parts.length < 2

        {
          resource_type: parts[0],
          profile_url: parts[1]
        }
      end

      def msg_line(title, text)
        "**#{title}**: #{text}"
      end

      def ms_checker_for(profile_metadata, section_context = nil)
        InfernoSuiteGenerator::MSChecker.new(profile_metadata, ms_checker_message_config(section_context))
      end

      def build_ms_outcome(profile_metadata, resources, section_context = nil)
        ms_helper = ms_checker_for(profile_metadata, section_context)
        ms_checks_results = check_ms_elements_populated(profile_metadata.resource, resources)

        {
          status: ms_helper.calculate_elements_status_message_level(ms_checks_results),
          message: ms_helper.build_report_message(profile_metadata, ms_checks_results)
        }
      end

      def process_profile(section_profile, resources_to_check_ms)
        profile_info_str, filtered_resources, resource_type =
          build_profile_context(section_profile, resources_to_check_ms)
        return report_missing_resources(profile_info_str) if filtered_resources.blank?

        profile_metadata = group_metadata_for(resource_type)
        outcome = build_ms_outcome(profile_metadata, filtered_resources, section_profile)
        add_message(outcome[:status], outcome[:message].join("\n\n"))

        outcome[:status]
      end

      def build_profile_context(section_profile, resources_to_check_ms)
        resource_type_and_profile = normalize_resource_type_and_profile(section_profile[:profile])
        resource_type, profile_url = resource_type_and_profile.values_at(:resource_type, :profile_url)
        profile_info_str = msg_line('Profile', "#{resource_type} — #{profile_url}")
        filtered_resources = resources_by_type(resources_to_check_ms, resource_type)

        [profile_info_str, filtered_resources, resource_type]
      end

      def resources_by_type(resources, resource_type)
        resources.filter { |resource| resource.resourceType == resource_type }
      end

      def group_metadata_for(resource_type)
        resource_metadata_raw = metadata_manager.group_metadata_by_resource_type(resource_type)
        InfernoSuiteGenerator::Generator::GroupMetadata.new(resource_metadata_raw)
      end

      def report_missing_resources(profile_info_str)
        full_message_data = [
          'No resources found',
          profile_info_str
        ]
        add_message('warning', full_message_data.join("\n\n"))
        nil
      end

      def section_context_label(section_context)
        short = section_context[:section_short]
        code = section_context[:section_code]
        short.present? ? "#{short} (#{code})" : code.to_s
      end

      def ms_checker_message_config(section_context)
        return {} if section_context.blank?

        section_label = section_context_label(section_context)

        {
          'mandatory_error_message' =>
            inject_section_into_ms_message(InfernoSuiteGenerator::MSChecker::MANDATORY_ERROR_MS_MESSAGE, section_label),
          'optional_warning_message' =>
            inject_section_into_ms_message(InfernoSuiteGenerator::MSChecker::OPTIONAL_MS_WARNING_MESSAGE,
                                           section_label),
          'okay_message' =>
            inject_section_into_ms_message(InfernoSuiteGenerator::MSChecker::MS_OKAY_MESSAGE, section_label)
        }
      end

      def inject_section_into_ms_message(message, section_label)
        message.sub('.', " in the #{section_label} section.")
      end

      def composition_section_check_ms_pass?(sections_codes:, bundle_resource:)
        results = check_ms_elements_populated_against_profiles(sections_profiles(sections_codes),
                                                               resources_to_check_ms(sections_codes: sections_codes,
                                                                                     bundle_resource: bundle_resource))
        !results_error?(results)
      end
    end
  end
end
