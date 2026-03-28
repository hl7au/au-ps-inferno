# frozen_string_literal: true

require 'yaml'
require_relative 'bundle_decorator'
require_relative 'composition_utils'
require_relative 'validator_helpers'
require_relative 'section_test_module'
require_relative 'section_names_mapping'
require_relative 'basic_test_contants_module'
require_relative 'basic_test_attester_module'
require_relative 'basic_test_subject_module'

module AUPSTestKit
  # A base class for all tests to decrease code duplication
  class BasicTest < Inferno::Test
    include CompositionUtils
    include ValidatorHelpers
    include SectionTestModule
    include SectionNamesMapping
    include BasicTestConstants
    include BasicTestSubjectModule
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
      has_error = false

      sections_data.each do |section_data|
        section = composition.section_by_code(section_data[:code])
        expected_profile_urls = section_data[:entries].flat_map do |e|
          (e[:profiles] || []).map do |p|
            p.to_s.include?('|') ? p.to_s.split('|').last : p
          end
        end.uniq

        if section.blank?
          body = section_entry_list_or_empty_reason(section_data, nil, normalized_sections_data)
          add_message('error',
                      "#{section_data[:short]} (#{section_data[:code]})\n\n#{body}")
          has_error = true
          next
        end

        empty_reason_populated = section.empty_reason_str.present?
        refs = section.entry_references
        has_entries = refs.any?

        bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
        all_entries_correct_profile = refs.all? do |ref|
          resource = bundle_resource.resource_by_reference(ref)
          next false unless resource.present?

          (resource.meta&.profile || []).any? { |prof| expected_profile_urls.include?(prof) }
        end
        any_entry_incorrect_profile = has_entries && !all_entries_correct_profile

        body = section_entry_list_or_empty_reason(section_data, section, normalized_sections_data)

        if any_entry_incorrect_profile
          add_message('error',
                      "#{section_data[:short]} (#{section_data[:code]})\n\n#{body}")
          has_error = true
        elsif empty_reason_populated && !has_entries
          add_message('warning',
                      "#{section_data[:short]} (#{section_data[:code]})\n\n#{body}")
        elsif has_entries && all_entries_correct_profile
          add_message('info',
                      "#{section_data[:short]} (#{section_data[:code]})\n\n#{body}")
        else
          add_message('error',
                      "#{section_data[:short]} (#{section_data[:code]}) - section has no entries and no emptyReason\n\n#{body}")
          has_error = true
        end
      end

      assert !has_error,
             'Some of the sections are not populated correctly. See the list of populated sections in messages tab.'
    end

    def section_entry_list_or_empty_reason(_section_data, section, _normalized_sections_data)
      return 'List of entry resources by type & profile: (section missing)' if section.blank?

      if section.entry_references.empty?
        return section.empty_reason_str.present? ? "emptyReason: #{section.empty_reason_str}" : 'No entries; no emptyReason.'
      end

      bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
      lines = section.entry_references.map do |ref|
        resource = bundle_resource.resource_by_reference(ref)
        if resource.present?
          profiles = (resource.meta&.profile || []).join(', ')
          "**#{ref}**: #{resource.resourceType} (#{profiles})"
        else
          "**#{ref}**: (resource not found)"
        end
      end
      lines.join("\n\n").to_s
    end

    def info_entry_resources_by_type_and_profile(sections_data, normalized_sections_data)
      title = '## List any entry resources by type & profile'
      result = []
      sections_data.each do |section_data|
        valid_resource_types = section_data[:entries].map do |entry|
          entry[:profiles]
        end.flatten.map { |profile| profile.split('|').first }.uniq
        section_title = "### #{section_data[:short]} (#{section_data[:code]})"
        result << section_title
        filtered_section_data = normalized_sections_data.find { |s| s['code'] == section_data[:code] }
        section_test_entity = SectionTestClass.new(filtered_section_data, scratch_bundle)
        (section_test_entity.references || []).each do |ref|
          existing_resource = section_test_entity.get_resource_by_reference(ref)
          next unless existing_resource.present?

          existing_resource_profiles = existing_resource.meta&.profile || []

          entity_can_present = valid_resource_types.include?(existing_resource.resourceType)
          result << " #{boolean_to_existent_string(entity_can_present)} **#{ref}**: #{existing_resource.resourceType} (#{existing_resource_profiles.join(', ')})"
        end
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
          result << "**#{element[:expression]}**: #{boolean_to_existent_string(resolve_path(section_resource,
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

    def get_resource_by_ref_and_check_profile(ref, profile, bundle)
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

    def validate_populated_elements_in_resource(fhirpath_to_get_resource, elements_array)
      return false unless scratch_bundle.present?

      resource = resolve_path(scratch_bundle, fhirpath_to_get_resource).first
      return false unless resource.present?

      info populated_paths_info(resource, elements_array)
      all_paths_are_populated?(resource, elements_array)
    end

    def validate_populated_sub_elements_in_composition(mandatory_ms, optional_ms)
      return false unless scratch_bundle.present?

      composition_resource = BundleDecorator.new(scratch_bundle.to_hash).composition_resource
      return false unless composition_resource.present?

      all_elements = mandatory_ms + optional_ms
      grouped_elements = all_elements.group_by { |element| element.split('.').first }
      any_parent_populated = grouped_elements.any? do |parent_path, _|
        resolve_path(composition_resource, parent_path).first.present?
      end
      mandatory_ms_result = grouped_elements.all? do |parent_path, sub_elements|
        next true unless resolve_path(composition_resource, parent_path).first.present?

        (mandatory_ms & sub_elements).all? { |el| resolve_path(composition_resource, el).first.present? }
      end

      # Error: when any mandatory Must Support sub-elements are missing (i.e. subject.reference and attester.mode).
      # Warning: when any optional Must Support sub-elements are missing (i.e. attester.time and attester.party)
      # Info: when all optional Must Support sub-elements are populated
      # One message for each complex element with Must Support sub-elements, i.e. subject and attester
      # Include list of Must Support sub-elements populated and missing.

      grouped_elements.each do |parent_path, sub_elements|
        parent_populated = resolve_path(composition_resource, parent_path).first.present?

        unless parent_populated
          add_message('warning',
                      "Must Support sub-elements correctly populated\n\nComposition\n\n**Complex element #{parent_path}** is not populated. Must Support sub-elements that would be validated: #{sub_elements.join(', ')}.")
          next
        end

        message_types = []
        sub_elements.each do |sub_element|
          sub_element_result = resolve_path(composition_resource, sub_element).first.present?
          sub_element_mandatory = mandatory_ms.include?(sub_element)
          message_types << if sub_element_result
                             'info'
                           else
                             sub_element_mandatory ? 'error' : 'warning'
                           end
        end
        uniq_message_types = message_types.uniq
        if uniq_message_types.include?('error')
          add_message('error', populated_paths_info(composition_resource, sub_elements))
          next
        end
        if uniq_message_types.include?('warning')
          add_message('warning', populated_paths_info(composition_resource, sub_elements))
          next
        end
        add_message('info', populated_paths_info(composition_resource, sub_elements))
      end

      skip_if !any_parent_populated, 'No complex element with Must Support sub-elements is populated'
      assert mandatory_ms_result,
             'Some of the mandatory Must Support sub-elements are not populated. See the list of populated sub-elements in messages tab.'
    end

    # Validates Must Support sub-elements only when the parent element is populated.
    # One message per complex element (error when any mandatory MS sub-element missing, warning when optional missing, info when all present).
    # Pass: all messages are info or warning. Fail: any message is error.
    #
    # @param resource [Hash, FHIR::Model] The resource to validate (e.g. Patient)
    # @param parent_groups [Array<Hash>] Each hash has :parent (String), :mandatory (Array<String>), :optional (Array<String>)
    # @return [Boolean] false if resource blank or no parent populated; true when validation ran (assert handles pass/fail)
    def validate_populated_sub_elements_when_parent_populated(resource, parent_groups)
      return false unless resource.present?

      any_parent_populated = false
      parent_groups.each do |group|
        parent_path = group[:parent]
        mandatory = group[:mandatory] || []
        optional = group[:optional] || []
        next unless resolve_path(resource, parent_path).first.present?

        any_parent_populated = true
        sub_elements = mandatory + optional
        message_types = sub_elements.map do |sub_element|
          sub_element_result = resolve_path(resource, sub_element).first.present?
          sub_element_mandatory = mandatory.include?(sub_element)
          if sub_element_result
            'info'
          else
            (sub_element_mandatory ? 'error' : 'warning')
          end
        end
        uniq_message_types = message_types.uniq
        message_type = if uniq_message_types.include?('error')
                         'error'
                       elsif uniq_message_types.include?('warning')
                         'warning'
                       else
                         'info'
                       end
        add_message(message_type, populated_paths_info(resource, sub_elements))
      end

      skip_if !any_parent_populated, 'No complex element with Must Support sub-elements is populated'
      mandatory_result = parent_groups.all? do |group|
        next true unless resolve_path(resource, group[:parent]).first.present?

        (group[:mandatory] || []).all? { |el| resolve_path(resource, el).first.present? }
      end
      assert mandatory_result,
             'When a mandatory Must Support sub-element is missing but the parent exists. See the list in messages tab.'
    end

    # Validates Must Support identifier slices (IHI, DVA, Medicare) on a resource (e.g. Patient).
    # Two messages: (1) Must support identifier slices correctly populated; (2) At least one slice populated.
    # Pass: all messages info or warning. No error level used.
    #
    # @param resource [Hash, FHIR::Model] The resource with identifier array (e.g. Patient)
    # @param slices [Array<Hash>] Each hash has :name (String) and :system (String URL)
    def validate_ms_identifier_slices_in_resource(resource, slices)
      return unless resource.present?

      identifiers = identifiers_from_resource(resource) || []
      slice_results = slices.map do |slice|
        ident = find_identifier_by_system(identifiers, slice[:system])
        { slice: slice, identifier: ident }
      end

      lines1 = slice_results.map do |r|
        if r[:identifier].present?
          type_str = identifier_type_display(r[:identifier])
          "✅ Populated: **#{r[:slice][:name]}** — system: #{r[:slice][:system]}#{type_str}"
        else
          "❌ Missing: **#{r[:slice][:name]}**"
        end
      end
      all_populated = slice_results.all? { |r| r[:identifier].present? }
      message_type1 = all_populated ? 'info' : 'warning'
      add_message(message_type1,
                  "Must support identifier slices correctly populated\n\n## List of Must Support identifier slices populated or missing\n\n#{lines1.join("\n\n")}")

      at_least_one = slice_results.any? { |r| r[:identifier].present? }
      message_type2 = at_least_one ? 'info' : 'warning'
      lines2 = slice_results.map do |r|
        if r[:identifier].present?
          "✅ Populated: **#{r[:slice][:name]}** — system: #{r[:slice][:system]}"
        else
          "❌ Missing: **#{r[:slice][:name]}**"
        end
      end
      add_message(message_type2,
                  "At least one Must Support identifier slices is populated\n\n## List of Must Support identifier slices populated or missing (system when populated)\n\n#{lines2.join("\n\n")}")
    end

    # Validates author Must Support identifier slices. One message: warning when any missing, info when all populated.
    # Includes author resource type and profiles; lists slices with type and system when populated.
    def validate_author_ms_identifier_slices(resource, slices, resource_type_str, profile_str)
      return unless resource.present? && slices.present?

      identifiers = identifiers_from_resource(resource) || []
      slice_results = slices.map do |slice|
        ident = find_identifier_by_system(identifiers, slice[:system])
        { slice: slice, identifier: ident }
      end

      author_header = "**Referenced author**: #{resource_type_str}#{" — #{profile_str}" if profile_str.present?}"
      lines = slice_results.map do |r|
        if r[:identifier].present?
          type_str = identifier_type_display(r[:identifier])
          "✅ Populated: **#{r[:slice][:name]}** — system: #{r[:slice][:system]}#{type_str}"
        else
          "❌ Missing: **#{r[:slice][:name]}**"
        end
      end
      all_populated = slice_results.all? { |r| r[:identifier].present? }
      message_type = all_populated ? 'info' : 'warning'
      add_message(message_type,
                  "Must support identifier slices correctly populated\n\n#{author_header}\n\n## List of Must Support identifier slices populated or missing (type and system when populated)\n\n#{lines.join("\n\n")}")
    end

    def validate_populated_elements_in_composition(elements_array, required: true)
      return false unless scratch_bundle.present?

      composition_resource = BundleDecorator.new(scratch_bundle.to_hash).composition_resource
      return false unless composition_resource.present?

      result = all_paths_are_populated?(composition_resource, elements_array)
      message_type = if result
                       'info'
                     else
                       required ? 'error' : 'warning'
                     end
      add_message(message_type, populated_paths_info(composition_resource, elements_array))

      return unless required

      assert result,
             'Some of the elements are not populated. See the list of populated elements in messages tab.'
    end

    def validate_populated_slices_in_composition(slices_array)
      passed = true
      return false unless scratch_bundle.present?

      composition_resource = BundleDecorator.new(scratch_bundle.to_hash).composition_resource
      return false unless composition_resource.present?

      slices_array.each do |slice|
        # TODO: event check is temporary hardcoded
        event = composition_resource.event_by_code('PCPR')
        required_ms_sub_elements = slice[:mandatory_ms_sub_elements].map { |element| "#{slice[:path]}.#{element}" }
        optional_ms_sub_elements = slice[:optional_ms_sub_elements].map { |element| "#{slice[:path]}.#{element}" }

        required_populated = all_paths_are_populated?(composition_resource, required_ms_sub_elements)
        optional_populated = all_paths_are_populated?(composition_resource, optional_ms_sub_elements)

        message_data = populated_paths_info(composition_resource, required_ms_sub_elements + optional_ms_sub_elements)
        slice_details_string = 'event:careProvisioningEvent'
        full_message_data = "#{message_data}\n\nSlice: **#{slice_details_string}**"

        if required_populated == false
          add_message('error', full_message_data)
          passed = false
          next
        end

        if optional_populated == false
          add_message('warning', full_message_data)
          next
        end

        if event.nil?
          add_message('warning', message_data)
          next
        end

        add_message('info', full_message_data)
      end

      assert passed, 'Some of the slices are not populated. See the list of populated slices in messages tab.'
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

      bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
      composition = bundle_resource.composition_resource
      all_errors = []

      section_codes_array.each do |section_code|
        section = composition.section_by_code(section_code)
        if section.blank?
          add_message(optional ? 'warning' : 'error', "#{get_section_name(section_code)} is missing")
          all_errors << true unless optional
          next
        else
          section_message_body = section_ms_elements_message(section, elements_array)
          all_populated = all_paths_are_populated?(section, elements_array)
          if all_populated
            add_message('info', "Section correctly populated\n\n#{section_message_body}")
          else
            add_message('error',
                        "For section with any mandatory Must Support element in section missing (i.e. title, code, text)\n\n#{section_message_body}")
            all_errors << true
          end
        end
      end

      assert all_errors.empty?,
             'Some of the sections are not populated. See the list of populated sections in messages tab.'
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

      bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
      composition = bundle_resource.composition_resource
      has_error = false

      section_codes_array.each do |section_code|
        section = composition.section_by_code(section_code)
        if section.blank?
          add_message('error', "#{get_section_name(section_code)} is missing")
          has_error = true
          next
        end
        section_message_body = section_ms_elements_message(section, elements_array)
        all_populated = all_paths_are_populated?(section, elements_array)
        if all_populated
          add_message('info', "Section correctly populated\n\n#{section_message_body}")
        else
          add_message('error',
                      "For section with any mandatory Must Support element in section missing (i.e. title, code, text)\n\n#{section_message_body}")
          has_error = true
        end
      end

      assert !has_error,
             'Some of the sections are not populated. See the list of populated sections in messages tab.'
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

    def author_resource
      return nil unless scratch_bundle.present?

      bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
      composition_resource = bundle_resource.composition_resource
      return nil unless composition_resource.present?

      author_ref = composition_resource.respond_to?(:author) && composition_resource.author.present? ? composition_resource.author.first : nil
      return nil unless author_ref.present?

      ref_str = author_ref.respond_to?(:reference) ? author_ref.reference : author_ref['reference']
      return nil if ref_str.blank?

      bundle_resource.resource_by_reference(ref_str)
    end

    def custodian_resource
      return nil unless scratch_bundle.present?

      bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
      composition_resource = bundle_resource.composition_resource
      return nil unless composition_resource.present?

      custodian_ref = composition_resource.respond_to?(:custodian) && composition_resource.custodian.present? ? composition_resource.custodian : nil
      return nil unless custodian_ref.present?

      ref_str = custodian_ref.respond_to?(:reference) ? custodian_ref.reference : custodian_ref['reference']
      return nil if ref_str.blank?

      bundle_resource.resource_by_reference(ref_str)
    end

    def load_metadata_yaml
      path = File.expand_path('../1.0.0-ballot/metadata.yaml', __dir__)
      return nil unless File.file?(path)

      YAML.safe_load_file(path, permitted_classes: [Symbol], aliases: true)
    end

    def composition_author_metadata
      data = load_metadata_yaml
      return [] unless data.present?

      data['author'] || data[:author] || []
    end

    def composition_custodian_metadata
      data = load_metadata_yaml
      return nil unless data.present?

      data['custodian'] || data[:custodian]
    end

    def custodian_complex_ms_elements(custodian_meta)
      return [] unless custodian_meta.present?

      elements = custodian_meta['elements'] || custodian_meta[:elements] || []
      elements.filter do |el|
        expr = (el['expression'] || el[:expression]).to_s
        id_str = (el['id'] || el[:id]).to_s
        !expr.include?('.') && !id_str.include?(':')
      end
    end

    def custodian_ms_subelement_parent_groups(custodian_meta)
      return [] unless custodian_meta.present?

      elements = custodian_meta['elements'] || custodian_meta[:elements] || []
      sub_elements = elements.filter do |el|
        expr = (el['expression'] || el[:expression]).to_s
        id_str = (el['id'] || el[:id]).to_s
        expr.include?('.') && !id_str.include?(':')
      end
      return [] if sub_elements.empty?

      grouped = sub_elements.group_by { |el| (el['expression'] || el[:expression]).to_s.split('.').first }
      grouped.map do |parent, els|
        mandatory = els.select do |e|
          ((e['min'] || e[:min]) || 0).positive?
        end.map { |e| e['expression'] || e[:expression] }
        optional = els.reject do |e|
          ((e['min'] || e[:min]) || 0).positive?
        end.map { |e| e['expression'] || e[:expression] }
        { parent: parent, mandatory: mandatory, optional: optional }
      end
    end

    # Returns author MS elements for the given resource type: complex elements only (no slices, no sub-elements).
    # Each element has :expression and :min; :expression has no "." and :id has no ":".
    def author_complex_ms_elements_for_type(author_metadata, resource_type)
      author_entry = author_metadata.find do |entry|
        type = entry['resource_type'] || entry[:resource_type]
        type.to_s == resource_type.to_s
      end
      return [] unless author_entry.present?

      elements = author_entry['elements'] || author_entry[:elements] || []
      elements.filter do |el|
        expr = (el['expression'] || el[:expression]).to_s
        id_str = (el['id'] || el[:id]).to_s
        !expr.include?('.') && !id_str.include?(':')
      end
    end

    # Returns parent groups for author MS sub-elements: complex elements that have sub-elements (no slices).
    # Each group has :parent, :mandatory (array of expression strings), :optional (array).
    def author_ms_subelement_parent_groups(author_metadata, resource_type)
      author_entry = author_metadata.find do |entry|
        type = entry['resource_type'] || entry[:resource_type]
        type.to_s == resource_type.to_s
      end
      return [] unless author_entry.present?

      elements = author_entry['elements'] || author_entry[:elements] || []
      sub_elements = elements.filter do |el|
        expr = (el['expression'] || el[:expression]).to_s
        id_str = (el['id'] || el[:id]).to_s
        expr.include?('.') && !id_str.include?(':')
      end
      return [] if sub_elements.empty?

      grouped = sub_elements.group_by { |el| (el['expression'] || el[:expression]).to_s.split('.').first }
      grouped.map do |parent, els|
        mandatory = els.select do |e|
          ((e['min'] || e[:min]) || 0).positive?
        end.map { |e| e['expression'] || e[:expression] }
        optional = els.reject do |e|
          ((e['min'] || e[:min]) || 0).positive?
        end.map { |e| e['expression'] || e[:expression] }
        { parent: parent, mandatory: mandatory, optional: optional }
      end
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

    # Validates author Must Support sub-elements: one message per complex element (with MS sub-elements).
    # warning when parent not populated; error/warning/info when parent populated depending on sub-elements.
    def validate_author_ms_subelements(resource, parent_groups, resource_type_str, profile_str)
      return unless resource.present?

      author_header = "**Referenced author**: #{resource_type_str}#{" — #{profile_str}" if profile_str.present?}"

      parent_groups.each do |group|
        parent_path = group[:parent]
        mandatory = group[:mandatory] || []
        optional = group[:optional] || []
        sub_elements = mandatory + optional

        parent_populated = resolve_path(resource, parent_path).first.present?

        unless parent_populated
          add_message('warning',
                      "Must Support sub-elements correctly populated\n\n#{author_header}\n\n**Complex element #{parent_path}** is not populated. Must Support sub-elements that would be validated: #{sub_elements.join(', ')}.")
          next
        end

        message_type = sub_elements.map do |sub_element|
          sub_element_result = resolve_path(resource, sub_element).first.present?
          sub_element_mandatory = mandatory.include?(sub_element)
          if sub_element_result
            'info'
          else
            (sub_element_mandatory ? 'error' : 'warning')
          end
        end.uniq

        level = if message_type.include?('error')
                  'error'
                else
                  (message_type.include?('warning') ? 'warning' : 'info')
                end
        list_lines = sub_elements.map do |expr|
          populated = resolve_path(resource, expr).first.present?
          "#{boolean_to_existent_string(populated)}: **#{expr}**"
        end
        add_message(level,
                    "Must Support sub-elements correctly populated\n\n#{author_header}\n\n## Complex element **#{parent_path}** — Must Support sub-elements populated or missing\n\n#{list_lines.join("\n\n")}")
      end

      mandatory_ok = parent_groups.all? do |group|
        next true unless resolve_path(resource, group[:parent]).first.present?

        (group[:mandatory] || []).all? { |el| resolve_path(resource, el).first.present? }
      end
      assert mandatory_ok,
             'When parent exists and any mandatory Must Support sub-element is missing. See the list in messages tab.'
    end

    def validate_custodian_ms_elements(resource, elements_config)
      return unless resource.present? && elements_config.present?

      expressions = elements_config.map { |el| el['expression'] || el[:expression] }.compact
      mandatory = elements_config.select do |el|
        ((el['min'] || el[:min]) || 0).positive?
      end.map { |el| el['expression'] || el[:expression] }
      optional = elements_config.reject do |el|
        ((el['min'] || el[:min]) || 0).positive?
      end.map { |el| el['expression'] || el[:expression] }

      mandatory_populated = mandatory.all? { |path| resolve_path(resource, path).first.present? }
      optional_populated = optional.all? { |path| resolve_path(resource, path).first.present? }

      list_lines = expressions.map do |expr|
        populated = resolve_path(resource, expr).first.present?
        "#{boolean_to_existent_string(populated)}: **#{expr}**"
      end
      add_message(
        calculate_message_level(
          failed: !mandatory_populated,
          warning: mandatory_populated && !optional_populated,
          info: mandatory_populated && optional_populated
        ),
        ms_elements_populated_message(resource, list_lines)
      )

      assert mandatory_populated,
             'When mandatory Must Support element is missing (e.g. name). See the list in messages tab.'
    end

    def validate_custodian_ms_subelements(resource, parent_groups, resource_type_str, profile_str)
      return unless resource.present?

      custodian_header = "**Referenced custodian**: #{resource_type_str}#{" — #{profile_str}" if profile_str.present?}"

      parent_groups.each do |group|
        parent_path = group[:parent]
        mandatory = group[:mandatory] || []
        optional = group[:optional] || []
        sub_elements = mandatory + optional

        parent_populated = resolve_path(resource, parent_path).first.present?

        unless parent_populated
          add_message('warning',
                      "Must Support sub-elements correctly populated\n\n#{custodian_header}\n\n**Complex element #{parent_path}** is not populated. Must Support sub-elements that would be validated: #{sub_elements.join(', ')}.")
          next
        end

        # Custodian: only warning when any sub-element missing, info when all populated (no error level per spec)
        all_populated = sub_elements.all? { |expr| resolve_path(resource, expr).first.present? }
        level = all_populated ? 'info' : 'warning'
        list_lines = sub_elements.map do |expr|
          populated = resolve_path(resource, expr).first.present?
          "#{boolean_to_existent_string(populated)}: **#{expr}**"
        end
        add_message(level,
                    "Must Support sub-elements correctly populated\n\n#{custodian_header}\n\n## Complex element **#{parent_path}** — Must Support sub-elements populated or missing\n\n#{list_lines.join("\n\n")}")
      end
    end

    def validate_custodian_ms_identifier_slices(resource, slices, resource_type_str, profile_str)
      return unless resource.present? && slices.present?

      identifiers = identifiers_from_resource(resource) || []
      slice_results = slices.map do |slice|
        ident = find_identifier_by_system(identifiers, slice[:system])
        { slice: slice, identifier: ident }
      end

      custodian_header = "**Referenced custodian**: #{resource_type_str}#{" — #{profile_str}" if profile_str.present?}"
      lines = slice_results.map do |r|
        if r[:identifier].present?
          type_str = identifier_type_display(r[:identifier])
          "✅ Populated: **#{r[:slice][:name]}** — system: #{r[:slice][:system]}#{type_str}"
        else
          "❌ Missing: **#{r[:slice][:name]}**"
        end
      end
      all_populated = slice_results.all? { |r| r[:identifier].present? }
      message_type = all_populated ? 'info' : 'warning'
      add_message(message_type,
                  "Must support identifier slices correctly populated\n\n#{custodian_header}\n\n## List of Must Support identifier slices populated or missing (type and system when populated)\n\n#{lines.join("\n\n")}")
    end

    def validate_author_ms_elements(resource, author_config_elements)
      return unless resource.present? && author_config_elements.present?

      expressions = author_config_elements.map { |el| el['expression'] || el[:expression] }.compact
      mandatory = author_config_elements.select do |el|
        ((el['min'] || el[:min]) || 0).positive?
      end.map { |el| el['expression'] || el[:expression] }
      optional = author_config_elements.reject do |el|
        ((el['min'] || el[:min]) || 0).positive?
      end.map { |el| el['expression'] || el[:expression] }

      mandatory_populated = mandatory.all? { |path| resolve_path(resource, path).first.present? }
      optional_populated = optional.all? { |path| resolve_path(resource, path).first.present? }

      message_type = if !mandatory_populated
                       'error'
                     elsif !optional_populated
                       'warning'
                     else
                       'info'
                     end

      list_lines = expressions.map do |expr|
        populated = resolve_path(resource, expr).first.present?
        "#{boolean_to_existent_string(populated)}: **#{expr}**"
      end

      add_message(message_type,
                  ms_elements_populated_message(resource, list_lines))

      assert mandatory_populated, 'When any mandatory Must Support element is missing. See the list in messages tab.'
    end

    def ms_elements_populated_message(resource, list_lines)
      "#{ms_elements_populated_title}#{prepare_resource_type_and_profile_str(resource,
                                                                             'author')}#{populated_elements_list(list_lines)}"
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

      if type_val.respond_to?(:coding) && type_val.coding.present?
        c = type_val.coding.first
        display = c.respond_to?(:display) ? c.display : c['display']
        code = c.respond_to?(:code) ? c.code : c['code']
        ", type: #{display.presence || code.presence || '—'}"
      elsif type_val.is_a?(Hash) && type_val['coding'].present?
        c = type_val['coding'].first
        ", type: #{c['display'].presence || c['code'].presence || '—'}"
      else
        ''
      end
    end

    def test_composition_author_ms_elements
      check_bundle_exists_in_scratch
      resource = author_resource
      skip_if resource.blank?, 'No author reference found on Composition'
      skip_if resource_type(resource) == 'Device',
              'Referenced author entry is type of Device; skip Must Support validation'

      author_meta = composition_author_metadata
      skip_if author_meta.blank?, 'No author metadata available'

      resource_type_str = resource_type(resource)
      complex_elements = author_complex_ms_elements_for_type(author_meta, resource_type_str)
      skip_if complex_elements.blank?, "No complex Must Support elements defined for author type #{resource_type_str}"

      validate_author_ms_elements(resource, complex_elements)
    end

    def test_composition_author_ms_subelements
      check_bundle_exists_in_scratch
      resource = author_resource
      skip_if resource.blank?, 'No author reference found on Composition'
      skip_if resource_type(resource) == 'Device', 'Referenced author resource type is Device'

      author_meta = composition_author_metadata
      skip_if author_meta.blank?, 'No author metadata available'

      resource_type_str = resource_type(resource)
      parent_groups = author_ms_subelement_parent_groups(author_meta, resource_type_str)
      skip_if parent_groups.blank?,
              'Referenced author resource type has no complex elements with Must Support sub-elements'

      rtype_str, profile_str = author_resource_type_and_profiles(resource)
      validate_author_ms_subelements(resource, parent_groups, rtype_str, profile_str)
    end

    def test_composition_author_ms_identifier_slices
      check_bundle_exists_in_scratch
      resource = author_resource
      skip_if resource.blank?, 'No author reference found on Composition'
      skip_if resource_type(resource) == 'Device', 'Referenced author resource type is Device'

      resource_type_str = resource_type(resource)
      slices = AUTHOR_MS_IDENTIFIER_SLICES_BY_TYPE[resource_type_str] || []
      skip_if slices.blank?,
              'No Must Support identifier slices are defined for the referenced author type (e.g. AU PS RelatedPerson)'

      rtype_str, profile_str = author_resource_type_and_profiles(resource)
      validate_author_ms_identifier_slices(resource, slices, rtype_str, profile_str)
    end

    def test_composition_custodian_ms_elements
      check_bundle_exists_in_scratch
      resource = custodian_resource
      skip_if resource.blank?, 'Custodian is not populated'

      custodian_meta = composition_custodian_metadata
      skip_if custodian_meta.blank?, 'No custodian metadata available'

      elements_config = custodian_complex_ms_elements(custodian_meta)
      skip_if elements_config.blank?, 'No complex Must Support elements defined for custodian'

      validate_custodian_ms_elements(resource, elements_config)
    end

    def test_composition_custodian_ms_subelements
      check_bundle_exists_in_scratch
      resource = custodian_resource
      skip_if resource.blank?, 'Custodian is not populated'

      custodian_meta = composition_custodian_metadata
      skip_if custodian_meta.blank?, 'No custodian metadata available'

      parent_groups = custodian_ms_subelement_parent_groups(custodian_meta)
      skip_if parent_groups.blank?, 'No complex elements with Must Support sub-elements defined for custodian'

      rtype_str, profile_str = author_resource_type_and_profiles(resource)
      validate_custodian_ms_subelements(resource, parent_groups, rtype_str, profile_str)
    end

    def test_composition_custodian_ms_identifier_slices
      check_bundle_exists_in_scratch
      resource = custodian_resource
      skip_if resource.blank?, 'Custodian is not populated'

      rtype_str, profile_str = author_resource_type_and_profiles(resource)
      validate_custodian_ms_identifier_slices(resource, ORGANIZATION_MS_IDENTIFIER_SLICES, rtype_str, profile_str)
    end
  end
end
