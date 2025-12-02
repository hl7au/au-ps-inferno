# frozen_string_literal: true

require_relative 'constants'
require_relative 'bundle_decorator'
require_relative 'composition_utils'

module AUPSTestKit
  # A base class for all tests to decrease code duplication
  class BasicTest < Inferno::Test
    extend Constants
    include CompositionUtils

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
        'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-bundle|0.4.0-draft'
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

    private

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
