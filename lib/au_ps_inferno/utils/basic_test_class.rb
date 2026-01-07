# frozen_string_literal: true

require_relative 'constants'
require_relative 'bundle_decorator'
require_relative 'composition_utils'
require_relative 'validator_helpers'

module AUPSTestKit
  # A base class for all tests to decrease code duplication
  class BasicTest < Inferno::Test
    extend Constants
    include CompositionUtils
    include ValidatorHelpers

    def check_other_sections
      check_bundle_exists_in_scratch
      composition_resource = BundleDecorator.new(scratch_bundle.to_hash).composition_resource
      other_section_codes = composition_resource.section_codes - Constants::ALL_SECTIONS
      info 'No other sections found' if other_section_codes.empty?
      other_section_codes.each do |section_code|
        check_composition_section_code(section_code, composition_resource)
      end
    end

    def bundle_mandatory_ms_elements_info
      check_bundle_exists_in_scratch
      info "**Mandatory Must Support elements populated**:\n\n#{mandatory_ms_elements_info}"
      info "**List entry resource by type (and meta.profile if exists)**:\n\n#{entry_resources_info}"
    end

    def mandatory_ms_elements_info
      [
        "**identifier**: #{boolean_to_humanized_string(identifier_info)}",
        "**type**: #{boolean_to_humanized_string(type_info)}",
        "**timestamp**: #{boolean_to_humanized_string(timestamp_info)}",
        "**All entry exists fullUrl**: #{boolean_to_humanized_string(all_entries_have_full_url_info)}"
      ].join("\n\n")
    end

    def skip_validation?
      false
    end

    def validate_ips_bundle
      check_bundle_exists_in_scratch
      validate_bundle(
        scratch_bundle,
        'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle|0.5.0-preview'
      )
    end

    def read_composition_mandatory_sections_info
      read_composition_sections_info(Constants::MANDATORY_SECTIONS)
    end

    def read_composition_optional_sections_info
      read_composition_sections_info(Constants::OPTIONAL_SECTIONS)
    end

    def read_composition_recommended_sections_info
      read_composition_sections_info(Constants::RECOMMENDED_SECTIONS)
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

    def validate_section_resources(section_name)
      assert bundle_resource.present?, 'Bundle resource not found'
      target_resources_hash = Constants::SECTIONS_NAMES_MAPPING[section_name]['resources']
      target_resource_types = extract_target_resource_types(target_resources_hash)
      is_multiprofile = check_multiprofile?(target_resource_types)

      bundle_resource_decorator = BundleDecorator.new(scratch_bundle)
      target_section = get_target_section(section_name, bundle_resource_decorator)
      section_references = get_section_references(target_section)

      section_errors, section_warnings = validate_all_section_references(
        section_references, bundle_resource_decorator, target_resources_hash,
        target_resource_types, is_multiprofile, target_section
      )

      report_validation_results(section_errors, section_warnings)
    end

    private

    def formatted_output_messages(messages_array)
      messages_ids = messages_array.map { |message| message[:id] }.uniq.sort
      messages_ids.map do |message_id|
        filtered_messages = messages_array.select do |message|
          message[:id] == message_id
        end.map { |message| message[:message] }.uniq
        "## #{message_id}:\n\n #{filtered_messages.map { |message| message }.join('\n\n')}"
      end.join("\n\n")
    end

    def extract_target_resource_types(target_resources_hash)
      target_resources_hash.keys.map do |resource_type_key|
        resource_type_key.to_s.split('|').first
      end
    end

    def check_multiprofile?(target_resource_types)
      target_resource_types.uniq.select do |resource_type|
        target_resource_types.count(resource_type) > 1
      end.length.positive?
    end

    def get_target_section(section_name, bundle_resource_decorator)
      composition_r = bundle_resource_decorator.composition_resource
      assert composition_r.present?, 'Composition resource not found'
      target_section = composition_r.section_by_code(Constants::SECTIONS_NAMES_MAPPING[section_name]['code'])
      assert target_section.present?, 'Section not found'
      target_section
    end

    def get_section_references(target_section)
      section_references = target_section.entry_references
      assert section_references.present?, 'Section references not found'
      section_references
    end

    def validate_all_section_references(section_references, bundle_resource, target_resources_hash,
                                        target_resource_types, is_multiprofile, target_section)
      section_errors = []
      section_warnings = []
      section_references.each_with_index do |ref, idx|
        errors, warnings = validate_section_reference(
          ref, idx, bundle_resource, target_resources_hash, target_resource_types,
          is_multiprofile, target_section
        )
        section_errors.concat(errors)
        section_warnings.concat(warnings)
      end
      [section_errors, section_warnings]
    end

    def report_validation_results(section_errors, section_warnings)
      add_message('error', "# Errors:\n\n #{formatted_output_messages(section_errors)}") if section_errors.any?
      warning "# Warnings:\n\n #{formatted_output_messages(section_warnings)}" if section_warnings.any?
      assert section_errors.none?, 'Some resources are not valid according to the section requirements'
    end

    def validate_section_reference(ref, idx, bundle_resource, target_resources_hash, target_resource_types,
                                   is_multiprofile, target_section)
      errors = []
      warnings = []
      resource = bundle_resource.resource_by_reference(ref)
      assert resource.present?, "Resource not found for reference #{ref}"
      assert target_resource_types.uniq.include?(resource.resourceType),
             "Resource #{resource.resourceType} is not expected for section #{target_section.code_display_str}"

      if target_resources_hash.keys.empty?
        resource_is_valid?(resource: resource)
        errors_found = messages.any? { |message| message[:type] == 'error' }
        assert !errors_found, "Resource does not conform to the resource #{resource.resourceType}"
      else
        target_resources_hash.each_key do |resource_type_key|
          resource_is_okay = true
          resource_type_info = target_resources_hash[resource_type_key]
          resource_type_key_splitted = resource_type_key.to_s.split('|')
          resource_type = resource_type_key_splitted.first
          resource_id = resource&.id
          next unless resource.resourceType == resource_type

          requirements = resource_type_info.keys.include?('requirements') ? resource_type_info['requirements'] : []
          if requirements.any?
            resource_is_okay = requirements.map do |req|
              find_a_value_at(resource, req['path']) == req['value']
            end.all?
          end

          if resource_is_okay
            profile_url = resource_type_key_splitted.last if resource_type_key_splitted.length == 2
            resource_is_valid?(resource: resource, profile_url: profile_url)
            messages.select { |message| message[:type] == 'error' }.each do |error_message|
              errors << { id: resource_id ? "#{resource_type}/#{resource_id}[#{idx}]" : "#{resource_type}[#{idx}]",
                          message: error_message[:message], profile: profile_url }
            end
            messages.select { |message| message[:type] == 'warning' }.each do |warning_message|
              warnings << { id: resource_id ? "#{resource_type}/#{resource_id}[#{idx}]" : "#{resource_type}[#{idx}]",
                            message: warning_message[:message], profile: profile_url }
            end
          end
          break unless is_multiprofile
        end
      end
      [errors, warnings]
    end

    def collect_messages(type)
      messages.select { |message| message[:type] == type }
    end

    def keep_messages(messages_array, type)
      messages_array.push(*collect_messages(type)) if collect_messages(type).any?
    end

    def entry_resources_info
      group_section_output(resolve_path(scratch_bundle, 'entry.resource').map do |resource|
        resource_type = resolve_path(resource, 'resourceType').first
        profiles = resolve_path(resource, 'meta.profile')
        profiles = profiles.sort
        result_message = profiles.empty? ? resource_type : "#{resource_type} (#{profiles.join(', ')})"
        result_message
      end).join("\n\n")
    end

    def validate_bundle(resource, profile_with_version)
      return if skip_validation?

      show_validator_version

      resource_is_valid?(resource: resource, profile_url: profile_with_version)
      errors_found = messages.any? { |message| message[:type] == 'error' }
      assert !errors_found, "Resource does not conform to the profile #{profile_with_version}"
    end

    def read_composition_sections_info(sections_array_codes)
      check_bundle_exists_in_scratch
      sections_array_codes.each do |section_code|
        check_composition_section_code(section_code, BundleDecorator.new(scratch_bundle.to_hash).composition_resource)
      end
    end
  end
end
