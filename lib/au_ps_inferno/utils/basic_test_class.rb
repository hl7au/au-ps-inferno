# frozen_string_literal: true

require_relative 'bundle_decorator'
require_relative 'composition_utils'
require_relative 'validator_helpers'
require_relative 'section_test_module'

module AUPSTestKit
  # A base class for all tests to decrease code duplication
  class BasicTest < Inferno::Test
    include CompositionUtils
    include ValidatorHelpers
    include SectionTestModule

    def check_other_sections(all_sections_data_codes, sections_codes_mapping)
      check_bundle_exists_in_scratch
      composition_resource = BundleDecorator.new(scratch_bundle.to_hash).composition_resource
      other_section_codes = composition_resource.section_codes - all_sections_data_codes
      info 'No other sections found' if other_section_codes.empty?
      other_section_codes.each do |section_code|
        check_composition_section_code(section_code, composition_resource, sections_codes_mapping)
      end
    end

    def bundle_mandatory_ms_elements_info
      check_bundle_exists_in_scratch
      passed = [identifier_info?, type_info?, timestamp_info?, all_entries_have_full_url_info?].all?
      info "**Must Support elements SHALL be populated when an element value is known and allowed to share**:\n\n#{mandatory_ms_elements_info}"
      info "**List any entry resources by type (and meta.profile if exists)**:\n\n#{entry_resources_info}"
      assert passed, 'Mandatory Must Support elements are not populated'
    end

    def mandatory_ms_elements_info
      [
        "**identifier**: #{boolean_to_humanized_string(identifier_info?)}",
        "**type**: #{boolean_to_humanized_string(type_info?)}",
        "**timestamp**: #{boolean_to_humanized_string(timestamp_info?)}",
        "**All entry exists fullUrl**: #{boolean_to_humanized_string(all_entries_have_full_url_info?)}"
      ].join("\n\n")
    end

    def skip_validation?
      false
    end

    def validate_ips_bundle
      check_bundle_exists_in_scratch
      validate_bundle(
        scratch_bundle,
        'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle|1.0.0-ballot'
      )
    end

    def operation_defined?(operations, op_def_url, names_arr, scratch_key)
      operation_defined = operations.any? do |operation|
        operation.definition == op_def_url || names_arr.include?(operation.name.downcase)
      end

      message_base = 'Server CapabilityStatement declares support for operation with operation definition'

      info "#{message_base} #{op_def_url}: #{boolean_to_humanized_string(operation_defined)}"

      scratch[scratch_key] = operation_defined
    end

    def operations
      fhir_get_capability_statement
      scratch[:capability_statement] = resource
      resource.rest&.flat_map do |rest|
        select_op(rest)
      end&.compact
    end

    def select_op(rest)
      rest.resource
          &.select { |res| res.respond_to?(:operation) }
          &.flat_map(&:operation)
    end

    def summary_op_defined?
      operation_defined?(operations, 'http://hl7.org/fhir/uv/ips/OperationDefinition/summary',
                         %w[summary patient-summary], :summary_op_defined)
    end

    def docref_op_defined?
      operation_defined?(operations, 'http://hl7.org/fhir/uv/ipa/OperationDefinition/docref', %w[docref],
                         :docref_op_defined)
    end

    private

    def validate_bundle(resource, profile_with_version)
      return if skip_validation?

      show_validator_version

      resource_is_valid?(resource: resource, profile_url: profile_with_version)
      errors_found = messages.any? { |message| message[:type] == 'error' }
      assert !errors_found, "Resource does not conform to the profile #{profile_with_version}"
    end

    def read_composition_sections_info(sections_data, normalized_sections_data)
      mandatory_ms_elements = sections_data.first[:ms_elements]
      sections_array_codes = sections_data.map { |section| section[:code] }
      required = sections_data.first[:required]
      bundle_exists = check_bundle_exists_in_scratch
      all_sections = all_sections_present_in_bundle?(sections_array_codes, scratch_bundle)
      elements_populated = all_mandatory_ms_elements_populated_in_sections?(
        sections_array_codes, scratch_bundle, mandatory_ms_elements
      )
      population_correct = profile_population_is_correct?(sections_data, scratch_bundle)
      info "Bundle exists: #{bundle_exists}, all sections present: #{all_sections}, all mandatory MS elements populated: #{elements_populated}, profile population correct: #{population_correct}, required: #{required}"
      info_sections_ms_elements(sections_data)
      info_entry_resources_by_type_and_profile(sections_data, normalized_sections_data)
    end

    def info_entry_resources_by_type_and_profile(sections_data, normalized_sections_data)
      title = '## List any entry resources by type & profile (follow reference) or emptyReason coding when populated'
      result = []
      sections_data.each do |section_data|
        valid_profiles = section_data[:entries].map do |entry|
          entry[:profiles]
        end.flatten.map { |profile| profile.split('|').last }.uniq
        section_title = "### #{section_data[:short]}(#{section_data[:code]})"
        result << section_title
        filtered_section_data = normalized_sections_data.find { |s| s['code'] == section_data[:code] }
        section_test_entity = SectionTestClass.new(filtered_section_data, scratch_bundle)
        (section_test_entity.references || []).each do |ref|
          existing_resource = section_test_entity.get_resource_by_reference(ref)
          next unless existing_resource.present?

          existing_resource_profiles = existing_resource.meta&.profile || []
          entity_can_present = existing_resource_profiles.any? { |profile| valid_profiles.include?(profile) }
          result << " #{boolean_to_humanized_string(entity_can_present)} **#{ref}**: #{existing_resource.resourceType} (#{existing_resource_profiles.join(', ')})"
        end
        info "result: #{result}"
        # result << validate_section_resources(filtered_section_data)
      end
      info [title, result.join("\n\n")].join("\n\n")
    end

    def info_sections_ms_elements(sections_configs)
      bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
      composition_resource = bundle_resource.composition_resource
      main_title = '## List Must Support elements populated or missing'
      result = []
      sections_configs.each do |section_config|
        section_resource = composition_resource.section_by_code(section_config[:code])
        next unless section_resource.present?

        title = "### #{section_config[:short]}(#{section_config[:code]})"
        result << title
        section_config[:ms_elements].each do |element|
          result << "**#{element[:expression]}**: #{boolean_to_humanized_string(resolve_path(section_resource,
                                                                                             element[:expression]).first.present?)}"
        end
      end
      info [main_title, result.join("\n\n")].join("\n\n")
    end

    def all_sections_present_in_bundle?(sections_array_codes, bundle)
      existing_section_codes = BundleDecorator.new(bundle.to_hash).composition_resource.section_codes
      sections_array_codes.all? { |section_code| existing_section_codes.include?(section_code) }
    end

    def all_mandatory_ms_elements_populated_in_sections?(sections_array_codes, bundle, mandatory_ms_elements)
      sections_array_codes.each do |section_code|
        section = BundleDecorator.new(bundle.to_hash).composition_resource.section_by_code(section_code)
        return false unless section.present?

        mandatory_ms_elements.map do |element|
          resolve_path(section, element[:expression]).first.present?
        end.all?
      end
    end

    def profile_population_is_correct?(sections_data, bundle)
      sections_data.map do |section_data|
        section = BundleDecorator.new(bundle.to_hash).composition_resource.section_by_code(section_data[:code])
        return false unless section.present?

        section_data[:entries].map do |entry|
          entry[:profiles].map do |profile|
            profile_population_is_correct_for_section?(section, profile, bundle)
          end
        end.all?
      end.all?
    end

    def profile_population_is_correct_for_section?(section, profile, bundle)
      bundle_resource = BundleDecorator.new(bundle.to_hash)
      section.entry_references.map do |reference|
        resource = bundle_resource.resource_by_reference(reference)
        next unless resource.present?
        next unless resource.meta.present?
        next unless resource.meta.profile.present?

        resource.meta.profile.include?(profile)
      end.all?
    end

    def get_resource_by_ref_and_check_profile(ref, profile, bundle)
      resource = BundleDecorator.new(bundle.to_hash).resource_by_reference(ref)
      return false unless resource.present?

      resource.meta.profile.include?(profile)
    end

    def populated_paths_info(resource, elements_array)
      title = '## List populated elements'
      result = elements_array.map do |element|
        "**#{element}**: #{boolean_to_humanized_string(resolve_path(resource, element).first.present?)}"
      end
      [title, result.join("\n\n")].join("\n\n")
    end

    def all_paths_are_populated?(resource, elements_array)
      elements_array.map do |element|
        resolve_path(resource, element).first.present?
      end.all?
    end

    def validate_populated_elements_in_resource(fhirpath_to_get_resource, elements_array)
      return false unless scratch_bundle.present?

      resource = resolve_path(scratch_bundle, fhirpath_to_get_resource).first
      return false unless resource.present?

      info populated_paths_info(resource, elements_array)
      all_paths_are_populated?(resource, elements_array)
    end

    def validate_populated_elements_in_composition(elements_array)
      return false unless scratch_bundle.present?

      composition_resource = BundleDecorator.new(scratch_bundle.to_hash).composition_resource
      return false unless composition_resource.present?

      info populated_paths_info(composition_resource, elements_array)
      all_paths_are_populated?(composition_resource, elements_array)
    end
  end
end
