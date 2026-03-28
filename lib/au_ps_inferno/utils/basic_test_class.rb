# frozen_string_literal: true

require 'yaml'
require_relative 'bundle_decorator'
require_relative 'composition_utils'
require_relative 'validator_helpers'
require_relative 'section_test_module'
require_relative 'section_names_mapping'
require_relative 'basic_test_contants_module'
require_relative 'attester/basic_test_attester_module'
require_relative 'subject/basic_test_subject_module'
require_relative 'author/basic_test_author_module'
require_relative 'custodian/basic_test_custodian_module'

module AUPSTestKit
  # A base class for all tests to decrease code duplication
  class BasicTest < Inferno::Test
    include CompositionUtils
    include ValidatorHelpers
    include SectionTestModule
    include SectionNamesMapping
    include BasicTestConstants
    include BasicTestSubjectModule
    include BasicTestAuthorModule
    include BasicTestCustodianModule
    include BasicTestAttesterModule

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
      message_type = passed ? 'info' : 'error'
      add_message(message_type,
                  "**List mandatory Must Support elements populated and missing**:\n\n#{mandatory_ms_elements_info}")
      info "**List any entry resources by type (and meta.profile if exists)**:\n\n#{entry_resources_info}"
      assert passed, 'Mandatory Must Support elements are not populated'
    end

    def mandatory_ms_elements_info
      [
        "**identifier**: #{boolean_to_existent_string(identifier_info?)}",
        "**type**: #{boolean_to_existent_string(type_info?)}",
        "**timestamp**: #{boolean_to_existent_string(timestamp_info?)}",
        "**All entry exists fullUrl**: #{boolean_to_existent_string(all_entries_have_full_url_info?)}"
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

      info "#{message_base} #{op_def_url}: #{boolean_to_existent_string(operation_defined)}"

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
      check_bundle_exists_in_scratch
      composition = BundleDecorator.new(scratch_bundle.to_hash).composition_resource
      has_error = sections_data.any? do |section_data|
        read_composition_section_row_error?(section_data, composition, normalized_sections_data)
      end

      assert !has_error,
             'Some of the sections are not populated correctly. See the list of populated sections in messages tab.'
    end

    def read_composition_section_row_error?(section_data, composition, normalized_sections_data)
      section = composition.section_by_code(section_data[:code])
      return composition_section_missing?(section_data, normalized_sections_data) if section.blank?

      read_composition_section_present_row_error?(section_data, section)
    end

    def read_composition_section_present_row_error?(section_data, section)
      bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
      expected_urls = expected_profile_urls_from_section_entries(section_data)
      refs = section.entry_references
      all_match = section_entries_match_expected_profiles?(bundle_resource, refs, expected_urls)
      body = section_entry_list_or_empty_reason(section_data, section, nil)
      flags = composition_section_row_flags(section, refs, all_match)
      read_composition_section_list_outcome?(section_data, body, flags)
    end

    def composition_section_row_flags(section, refs, all_match)
      {
        any_wrong: refs.any? && !all_match,
        empty_reason: section.empty_reason_str.present?,
        has_entries: refs.any?,
        all_match: all_match
      }
    end

    def composition_section_missing?(section_data, normalized_sections_data)
      body = section_entry_list_or_empty_reason(section_data, nil, normalized_sections_data)
      add_message('error', "#{section_data[:short]} (#{section_data[:code]})\n\n#{body}")
      true
    end

    def expected_profile_urls_from_section_entries(section_data)
      section_data[:entries].flat_map do |e|
        (e[:profiles] || []).map do |p|
          p.to_s.include?('|') ? p.to_s.split('|').last : p
        end
      end.uniq
    end

    def section_entries_match_expected_profiles?(bundle_resource, refs, expected_profile_urls)
      refs.all? do |ref|
        resource = bundle_resource.resource_by_reference(ref)
        next false unless resource.present?

        (resource.meta&.profile || []).any? { |prof| expected_profile_urls.include?(prof) }
      end
    end

    def read_composition_section_list_outcome?(section_data, body, flags)
      header = "#{section_data[:short]} (#{section_data[:code]})"
      composition_section_list_dispatch?(header, body, flags)
    end

    def composition_section_list_dispatch?(header, body, flags)
      return composition_section_list_on_error?(header, body) if flags[:any_wrong]
      return composition_section_list_on_warning_empty?(header, body) if flags[:empty_reason] && !flags[:has_entries]
      return composition_section_list_on_info_ok?(header, body) if flags[:has_entries] && flags[:all_match]

      composition_section_list_on_no_entries_error?(header, body)
    end

    def composition_section_list_on_error?(header, body)
      add_message('error', "#{header}\n\n#{body}")
      true
    end

    def composition_section_list_on_warning_empty?(header, body)
      add_message('warning', "#{header}\n\n#{body}")
      false
    end

    def composition_section_list_on_info_ok?(header, body)
      add_message('info', "#{header}\n\n#{body}")
      false
    end

    def composition_section_list_on_no_entries_error?(header, body)
      add_message('error', "#{header} - section has no entries and no emptyReason\n\n#{body}")
      true
    end

    def section_entry_list_or_empty_reason(_section_data, section, _normalized_sections_data)
      return 'List of entry resources by type & profile: (section missing)' if section.blank?
      return empty_section_entry_reason_line(section) if section.entry_references.empty?

      bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
      lines = section.entry_references.map { |ref| section_entry_line_for_reference(bundle_resource, ref) }
      lines.join("\n\n").to_s
    end

    def empty_section_entry_reason_line(section)
      if section.empty_reason_str.present?
        "emptyReason: #{section.empty_reason_str}"
      else
        'No entries; no emptyReason.'
      end
    end

    def section_entry_line_for_reference(bundle_resource, ref)
      resource = bundle_resource.resource_by_reference(ref)
      if resource.present?
        profiles = (resource.meta&.profile || []).join(', ')
        "**#{ref}**: #{resource.resourceType} (#{profiles})"
      else
        "**#{ref}**: (resource not found)"
      end
    end

    def info_entry_resources_by_type_and_profile(sections_data, normalized_sections_data)
      title = '## List any entry resources by type & profile'
      result = []
      sections_data.each do |section_data|
        result.concat(info_entry_lines_for_section(section_data, normalized_sections_data))
      end
      info [title, result.join("\n\n")].join("\n\n")
    end

    def info_entry_lines_for_section(section_data, normalized_sections_data)
      valid_types = info_section_valid_resource_types(section_data)
      header = "### #{section_data[:short]} (#{section_data[:code]})"
      filtered = normalized_sections_data.find { |s| s['code'] == section_data[:code] }
      entity = SectionTestClass.new(filtered, scratch_bundle)
      ref_lines = info_entry_resource_ref_lines(entity, valid_types)
      [header, *ref_lines]
    end

    def info_entry_resource_ref_lines(entity, valid_types)
      (entity.references || []).filter_map do |ref|
        res = entity.get_resource_by_reference(ref)
        next unless res.present?

        profiles = res.meta&.profile || []
        ok = valid_types.include?(res.resourceType)
        " #{boolean_to_existent_string(ok)} **#{ref}**: #{res.resourceType} (#{profiles.join(', ')})"
      end
    end

    def info_section_valid_resource_types(section_data)
      section_data[:entries].map { |entry| entry[:profiles] }.flatten.map { |profile| profile.split('|').first }.uniq
    end

    def info_sections_ms_elements(sections_configs)
      bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
      composition_resource = bundle_resource.composition_resource
      main_title = '## List Must Support elements populated or missing'
      result = []
      sections_configs.each do |section_config|
        lines = info_section_ms_element_lines(composition_resource, section_config)
        result.concat(lines) if lines
      end
      info [main_title, result.join("\n\n")].join("\n\n")
    end

    def info_section_ms_element_lines(composition_resource, section_config)
      section_resource = composition_resource.section_by_code(section_config[:code])
      return nil unless section_resource.present?

      title = "### #{section_config[:short]}(#{section_config[:code]})"
      element_lines = section_config[:ms_elements].map do |element|
        present = resolve_path(section_resource, element[:expression]).first.present?
        "**#{element[:expression]}**: #{boolean_to_existent_string(present)}"
      end
      [title, *element_lines]
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
            profile_population_is_correct_for_section?(section, profile.split('|').first, bundle)
          end
        end.all?
      end.all?
    end

    def profile_population_is_correct_for_section?(section, resource_type, bundle)
      bundle_resource = BundleDecorator.new(bundle.to_hash)
      section.entry_references.map do |reference|
        resource = bundle_resource.resource_by_reference(reference)
        resource.resourceType == resource_type
      end.all?
    end

    def resource_by_ref_matches_profile?(ref, profile, bundle)
      resource = BundleDecorator.new(bundle.to_hash).resource_by_reference(ref)
      return false unless resource.present?

      resource.meta.profile.include?(profile)
    end

    def populated_paths_info(resource, elements_array)
      title = '## List of populated elements'
      result = elements_array.map do |element|
        "#{boolean_to_existent_string(resolve_path(resource, element).first.present?)}: **#{element}**"
      end
      [title, result.join("\n\n")].join("\n\n")
    end

    def populated_paths_info_raw(resource, elements_array)
      elements_array.map do |element|
        "#{boolean_to_existent_string(resolve_path(resource, element).first.present?)}: **#{element}**"
      end
    end

    def all_paths_are_populated?(resource, elements_array)
      elements_array.map do |element|
        resolve_path(resource, element).first.present?
      end.all?
    end

    def populated_elements_in_resource?(fhirpath_to_get_resource, elements_array)
      return false unless scratch_bundle.present?

      resource = resolve_path(scratch_bundle, fhirpath_to_get_resource).first
      return false unless resource.present?

      info populated_paths_info(resource, elements_array)
      all_paths_are_populated?(resource, elements_array)
    end

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

    # Validates Must Support identifier slices (IHI, DVA, Medicare) on a resource (e.g. Patient).
    # Two messages: (1) Must support identifier slices correctly populated; (2) At least one slice populated.
    # Pass: all messages info or warning. No error level used.
    #
    # @param resource [Hash, FHIR::Model] The resource with identifier array (e.g. Patient)
    # @param slices [Array<Hash>] Each hash has :name (String) and :system (String URL)
    def validate_ms_identifier_slices_in_resource(resource, slices)
      return unless resource.present?

      slice_results = build_ms_identifier_slice_results(identifiers_from_resource(resource) || [], slices)
      add_ms_identifier_slices_populated_message(slice_results)
      add_ms_identifier_slices_at_least_one_message(slice_results)
    end

    def add_ms_identifier_slices_populated_message(slice_results)
      lines = slice_results.map { |r| ms_identifier_slice_line_with_type(r) }
      heading = '## List of Must Support identifier slices populated or missing'
      body = ['Must support identifier slices correctly populated', heading, lines.join("\n\n")].join("\n\n")
      add_message(slice_results.all? { |r| r[:identifier].present? } ? 'info' : 'warning', body)
    end

    def add_ms_identifier_slices_at_least_one_message(slice_results)
      lines = slice_results.map { |r| ms_identifier_slice_line_system_only(r) }
      heading = '## List of Must Support identifier slices populated or missing (system when populated)'
      intro = 'At least one Must Support identifier slices is populated'
      body = [intro, heading, lines.join("\n\n")].join("\n\n")
      add_message(slice_results.any? { |r| r[:identifier].present? } ? 'info' : 'warning', body)
    end

    def build_ms_identifier_slice_results(identifiers, slices)
      slices.map do |slice|
        ident = find_identifier_by_system(identifiers, slice[:system])
        { slice: slice, identifier: ident }
      end
    end

    def ms_identifier_slice_line_with_type(result)
      if result[:identifier].present?
        type_str = identifier_type_display(result[:identifier])
        "✅ Populated: **#{result[:slice][:name]}** — system: #{result[:slice][:system]}#{type_str}"
      else
        "❌ Missing: **#{result[:slice][:name]}**"
      end
    end

    def ms_identifier_slice_line_system_only(result)
      if result[:identifier].present?
        "✅ Populated: **#{result[:slice][:name]}** — system: #{result[:slice][:system]}"
      else
        "❌ Missing: **#{result[:slice][:name]}**"
      end
    end

    def validate_populated_elements_in_composition(elements_array, required: true)
      composition_resource = composition_resource_from_scratch
      return false unless composition_resource.present?

      result = all_paths_are_populated?(composition_resource, elements_array)
      msg_type = composition_elements_message_type(result, required)
      add_message(msg_type, populated_paths_info(composition_resource, elements_array))
      assert_composition_elements_if_required(result, required)
    end

    def composition_elements_message_type(result, required)
      return 'info' if result

      required ? 'error' : 'warning'
    end

    def assert_composition_elements_if_required(result, required)
      return unless required

      assert result,
             'Some of the elements are not populated. See the list of populated elements in messages tab.'
    end

    def validate_populated_slices_in_composition(slices_array)
      return false unless scratch_bundle.present?

      composition_resource = BundleDecorator.new(scratch_bundle.to_hash).composition_resource
      return false unless composition_resource.present?

      # TODO: event check is temporary hardcoded
      event = composition_resource.event_by_code('PCPR')
      passed = slices_array.all? do |slice|
        composition_slice_validation_passes?(composition_resource, slice, event)
      end

      assert passed, 'Some of the slices are not populated. See the list of populated slices in messages tab.'
    end

    def composition_slice_validation_passes?(composition_resource, slice, event)
      paths = composition_slice_element_paths(slice)
      message_data = populated_paths_info(composition_resource, paths[:combined])
      full_data = composition_slice_full_message_data(message_data)
      return false unless composition_slice_required_paths_ok?(composition_resource, paths, full_data)

      composition_slice_optional_and_event_outcome?(composition_resource, paths, full_data, message_data, event)
    end

    def composition_slice_full_message_data(message_data)
      "#{message_data}\n\nSlice: **event:careProvisioningEvent**"
    end

    def composition_slice_required_paths_ok?(composition_resource, paths, full_data)
      return true if all_paths_are_populated?(composition_resource, paths[:required])

      add_message('error', full_data)
      false
    end

    def composition_slice_optional_and_event_outcome?(composition_resource, paths, full_data, message_data, event)
      unless all_paths_are_populated?(composition_resource, paths[:optional])
        add_message('warning', full_data)
        return true
      end
      return composition_slice_warn_if_event_nil?(message_data) if event.nil?

      add_message('info', full_data)
      true
    end

    def composition_slice_warn_if_event_nil?(message_data)
      add_message('warning', message_data)
      true
    end

    def composition_slice_element_paths(slice)
      base = slice[:path]
      required = slice[:mandatory_ms_sub_elements].map { |el| "#{base}.#{el}" }
      optional = slice[:optional_ms_sub_elements].map { |el| "#{base}.#{el}" }
      { required: required, optional: optional, combined: required + optional }
    end

    def validate_populated_undefined_sections_in_bundle(sections_code_to_filter, elements_array)
      skip_if scratch_bundle.blank?, 'No Bundle resource provided'

      bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
      sections_to_validate = bundle_resource.composition_resource.section_codes.filter do |section_code|
        !sections_code_to_filter.include?(section_code)
      end

      skip_if sections_to_validate.blank?, 'No sections to validate'
      validate_populated_sections_in_bundle(sections_to_validate, elements_array, optional: true)
    end

    def validate_populated_sections_in_bundle(section_codes_array, elements_array, optional: false)
      skip_if scratch_bundle.blank?, 'No Bundle resource provided'
      skip_if section_codes_array.blank?, 'No sections to validate'

      composition = BundleDecorator.new(scratch_bundle.to_hash).composition_resource
      all_errors = section_codes_array.filter_map do |section_code|
        section_bundle_row_failure?(composition, section_code, elements_array, optional: optional)
      end

      assert all_errors.empty?,
             'Some of the sections are not populated. See the list of populated sections in messages tab.'
    end

    def section_bundle_row_failure?(composition, section_code, elements_array, optional:)
      section = composition.section_by_code(section_code)
      return section_bundle_blank_outcome?(section_code, optional) if section.blank?

      section_bundle_ms_population_outcome?(section, elements_array)
    end

    def section_bundle_blank_outcome?(section_code, optional)
      add_message(optional ? 'warning' : 'error', "#{get_section_name(section_code)} is missing")
      optional ? false : true
    end

    def section_bundle_ms_population_outcome?(section, elements_array)
      body = section_ms_elements_message(section, elements_array)
      return section_bundle_all_ms_ok?(body) if all_paths_are_populated?(section, elements_array)

      add_message('error', section_ms_missing_mandatory_message(body))
      true
    end

    def section_bundle_all_ms_ok?(body)
      add_message('info', "Section correctly populated\n\n#{body}")
      false
    end

    def section_ms_missing_mandatory_message(body)
      "For section with any mandatory Must Support element in section missing (i.e. title, code, text)\n\n#{body}"
    end

    def section_ms_elements_message(section, elements_array)
      title = "### #{section.code_display_str}"
      elements_list = elements_array.map do |element|
        "**#{element}**: #{boolean_to_existent_string(resolve_path(section, element).first.present?)}"
      end.join("\n\n")
      [title, 'List of Must Support elements populated or missing:', elements_list].join("\n\n")
    end

    def mixed_validate_populated_sections_in_bundle(section_codes_array, elements_array)
      skip_if scratch_bundle.blank?, 'No Bundle resource provided'
      skip_if section_codes_array.blank?, 'No sections to validate'

      composition = BundleDecorator.new(scratch_bundle.to_hash).composition_resource
      has_error = section_codes_array.any? do |section_code|
        mixed_section_bundle_row_error?(composition, section_code, elements_array)
      end

      assert !has_error,
             'Some of the sections are not populated. See the list of populated sections in messages tab.'
    end

    def mixed_section_bundle_row_error?(composition, section_code, elements_array)
      section = composition.section_by_code(section_code)
      return section_bundle_blank_outcome?(section_code, false) if section.blank?

      section_bundle_ms_population_outcome?(section, elements_array)
    end

    def calculate_message_level(failed: false, warning: false, info: false)
      return 'error' if failed
      return 'warning' if warning
      return 'info' if info

      'info'
    end

    def resource_type(resource)
      return nil unless resource.present?

      resource.respond_to?(:resourceType) ? resource.resourceType : resource['resourceType']
    end

    def load_metadata_yaml
      path = File.expand_path('../1.0.0-ballot/metadata.yaml', __dir__)
      return nil unless File.file?(path)

      YAML.safe_load_file(path, permitted_classes: [Symbol], aliases: true)
    end

    def author_resource_type_and_profiles(resource)
      return ['', ''] unless resource.present?

      resource_type_str = resource.respond_to?(:resourceType) ? resource.resourceType : resource['resourceType']
      profiles = resource_profiles(resource)
      profile_str = profiles.is_a?(Array) ? profiles.join(', ') : profiles.to_s
      [resource_type_str.to_s, profile_str.to_s]
    end

    def resource_profiles(resource)
      return [] unless resource.present?

      if resource.respond_to?(:meta) && resource.meta&.profile.present?
        resource.meta.profile
      elsif resource.is_a?(Hash)
        resource.dig('meta', 'profile') || []
      else
        []
      end
    end

    def ms_elements_populated_message(resource, list_lines)
      ref = prepare_resource_type_and_profile_str(resource, 'author')
      "#{ms_elements_populated_title}#{ref}#{populated_elements_list(list_lines)}"
    end

    def ms_elements_populated_title
      'Must Support elements correctly populated'
    end

    def prepare_resource_type_and_profile_str(resource, human_readable_name)
      resource_type_str = resource.respond_to?(:resourceType) ? resource.resourceType : resource['resourceType']
      profiles = resource_profiles(resource)
      profile_str = profiles.is_a?(Array) && profiles.length.positive? ? profiles.join(', ') : nil

      result = [resource_type_str, profile_str].compact.join(' — ')

      "\n\n**Referenced #{human_readable_name}**: #{result}"
    end

    def populated_elements_list(list_lines)
      return '' if list_lines.blank?

      "\n\n## List of Must Support elements (complex) populated or missing\n\n#{list_lines.join("\n\n")}"
    end

    def get_extension_value_by_url(resouce, url)
      result = resouce&.extension&.find { |ext| ext.url == url }

      result.value if result.present?
    end

    def identifiers_from_resource(resource)
      return nil unless resource.present?

      if resource.respond_to?(:identifier)
        resource.identifier
      elsif resource.is_a?(Hash)
        resource['identifier']
      end
    end

    def identifier_system(ident)
      return nil unless ident.present?

      ident.respond_to?(:system) ? ident.system : ident['system']
    end

    def find_identifier_by_system(identifiers, system_url)
      return nil if identifiers.blank? || system_url.blank?

      identifiers.find { |ident| identifier_system(ident).to_s.strip == system_url.to_s.strip }
    end

    def identifier_type_display(ident)
      return '' unless ident.present?

      type_val = ident.respond_to?(:type) ? ident.type : ident['type']
      return '' if type_val.blank?

      coding_suffix_from_type_value(type_val)
    end

    def coding_suffix_from_type_value(type_val)
      return coding_display_suffix(type_val.coding.first) if type_val.respond_to?(:coding) && type_val.coding.present?
      return coding_display_suffix_hash(type_val['coding'].first) if type_val.is_a?(Hash) && type_val['coding'].present?

      ''
    end

    def coding_display_suffix(coding)
      display = coding.respond_to?(:display) ? coding.display : coding['display']
      code = coding.respond_to?(:code) ? coding.code : coding['code']
      ", type: #{display.presence || code.presence || '—'}"
    end

    def coding_display_suffix_hash(coding)
      ", type: #{coding['display'].presence || coding['code'].presence || '—'}"
    end
  end
end
