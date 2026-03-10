# frozen_string_literal: true

require 'yaml'
require_relative 'bundle_decorator'
require_relative 'composition_utils'
require_relative 'validator_helpers'
require_relative 'section_test_module'
require_relative 'section_names_mapping'

module AUPSTestKit
  # A base class for all tests to decrease code duplication
  class BasicTest < Inferno::Test
    include CompositionUtils
    include ValidatorHelpers
    include SectionTestModule
    include SectionNamesMapping

    # AU PS Patient Must Support sub-elements: validate when parent (name, telecom, communication) is populated.
    # communication.language is mandatory when communication is present; all others optional.
    PATIENT_MS_SUBELEMENT_GROUPS = [
      { parent: 'name', mandatory: [], optional: %w[name.use name.text name.family name.given] },
      { parent: 'telecom', mandatory: [], optional: %w[telecom.system telecom.value telecom.use] },
      { parent: 'communication', mandatory: ['communication.language'], optional: ['communication.preferred'] }
    ].freeze

    # AU PS Patient Must Support identifier slices (optional). System URLs for IHI, DVA, Medicare.
    PATIENT_MS_IDENTIFIER_SLICES = [
      { name: 'IHI', system: 'http://ns.electronichealth.net.au/id/hi/ihi/1.0' },
      { name: 'DVA', system: 'http://ns.electronichealth.net.au/id/dva' },
      { name: 'MEDICARE', system: 'http://ns.electronichealth.net.au/id/medicare-number' }
    ].freeze
    ORGANIZATION_MS_IDENTIFIER_SLICES = [
      { name: 'ABN', system: 'http://hl7.org.au/id/abn' },
      { name: 'HPIO', system: 'http://ns.electronichealth.net.au/id/hi/hpio/1.0' }
    ].freeze
    PRACTITIONER_ROLE_MS_IDENTIFIER_SLICES = [
      { name: 'MEDICARE PROVIDER', system: 'http://ns.electronichealth.net.au/id/medicare-provider-number' }
    ].freeze
    PRACTITIONER_MS_IDENTIFIER_SLICES = [
      { name: 'HPII', system: 'http://ns.electronichealth.net.au/id/hi/hpii/1.0' }
    ].freeze

    # Author resource type -> Must Support identifier slices (empty for Device, RelatedPerson).
    AUTHOR_MS_IDENTIFIER_SLICES_BY_TYPE = {
      'Practitioner' => PRACTITIONER_MS_IDENTIFIER_SLICES,
      'PractitionerRole' => PRACTITIONER_ROLE_MS_IDENTIFIER_SLICES,
      'Patient' => PATIENT_MS_IDENTIFIER_SLICES,
      'Organization' => ORGANIZATION_MS_IDENTIFIER_SLICES,
      'RelatedPerson' => [],
      'Device' => []
    }.freeze

    SUBJECT_OPTIONAL_SLICE_URLS = {
      'indigenousStatus' => 'http://hl7.org.au/fhir/StructureDefinition/indigenous-status',
      'genderIdentity' => 'http://hl7.org/fhir/StructureDefinition/individual-genderIdentity',
      'individualPronouns' => 'http://hl7.org/fhir/StructureDefinition/individual-pronouns'
    }.freeze

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
        section = composition.section_by_code(section_data[:code])
        body = section_entry_list_or_empty_reason(section_data, section, normalized_sections_data)
        process_one_section_read?(section_data, section, body, expected_profile_urls_for_section(section_data))
      end
      assert !has_error,
             'Some of the sections are not populated correctly. See the list of populated sections in messages tab.'
    end

    def section_entry_list_or_empty_reason(_section_data, section, _normalized_sections_data)
      return 'List of entry resources by type & profile: (section missing)' if section.blank?
      return section_empty_reason_text(section) if section.entry_references.empty?

      bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
      section_entry_lines(section.entry_references, bundle_resource).join("\n\n").to_s
    end

    def info_entry_resources_by_type_and_profile(sections_data, normalized_sections_data)
      title = '## List any entry resources by type & profile'
      result = sections_data.flat_map do |section_data|
        valid_types = valid_resource_types_for_section(section_data)
        build_info_entry_section_lines(section_data, normalized_sections_data, valid_types)
      end
      info [title, result.join("\n\n")].join("\n\n")
    end

    def info_sections_ms_elements(sections_configs)
      bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
      composition_resource = bundle_resource.composition_resource
      main_title = '## List Must Support elements populated or missing'
      result = sections_configs.filter_map do |section_config|
        section_resource = composition_resource.section_by_code(section_config[:code])
        section_ms_elements_result(section_config, section_resource) if section_resource.present?
      end.flatten
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

    def validate_populated_elements_in_resource?(fhirpath_to_get_resource, elements_array)
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

      grouped = (mandatory_ms + optional_ms).group_by { |el| el.split('.').first }
      any_parent = grouped.any? { |p, _| resolve_path(composition_resource, p).first.present? }
      mandatory_ok = composition_sub_elements_mandatory_result(grouped, mandatory_ms, composition_resource)
      composition_run_sub_group_messages(composition_resource, grouped, mandatory_ms)
      skip_if !any_parent, 'No complex element with Must Support sub-elements is populated'
      assert mandatory_ok,
             'Some of the mandatory Must Support sub-elements are not populated. See the list in messages tab.'
    end

    # Validates Must Support sub-elements only when the parent element is populated.
    # One message per complex element (error when any mandatory MS sub-element missing,
    # warning when optional missing, info when all present). Pass: all info or warning. Fail: any error.
    #
    # @param resource [Hash, FHIR::Model] The resource to validate (e.g. Patient)
    # @param parent_groups [Array<Hash>] Each hash has :parent (String), :mandatory, :optional (Array<String>)
    # @return [Boolean] false if resource blank or no parent populated; true when validation ran
    def validate_populated_sub_elements_when_parent_populated(resource, parent_groups)
      return false unless resource.present?

      any_parent = process_parent_groups_sub_element_messages(resource, parent_groups)
      skip_if !any_parent, 'No complex element with Must Support sub-elements is populated'
      assert parent_groups_mandatory_result(resource, parent_groups),
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

      slice_results = identifier_slice_results(resource, slices)
      add_message(identifier_slices_message_type(slice_results, :all),
                  "Must support identifier slices correctly populated\n\n## List of Must Support identifier slices " \
                  "populated or missing\n\n#{identifier_slice_lines_with_type(slice_results).join("\n\n")}")
      add_message(identifier_slices_message_type(slice_results, :any),
                  "At least one Must Support identifier slices is populated\n\n## List of Must Support identifier " \
                  "slices populated or missing (system when populated)\n\n#{identifier_slice_lines_simple(slice_results).join("\n\n")}")
    end

    # Validates author Must Support identifier slices. One message: warning when any missing, info when all populated.
    # Includes author resource type and profiles; lists slices with type and system when populated.
    def validate_author_ms_identifier_slices(resource, slices, resource_type_str, profile_str)
      return unless resource.present? && slices.present?

      slice_results = identifier_slice_results(resource, slices)
      header = "**Referenced author**: #{resource_type_str}#{" — #{profile_str}" if profile_str.present?}"
      lines = identifier_slice_lines_with_type(slice_results)
      msg_type = identifier_slices_message_type(slice_results, :all)
      add_message(msg_type,
                  "Must support identifier slices correctly populated\n\n#{header}\n\n## List of Must Support " \
                  "identifier slices populated or missing (type and system when populated)\n\n#{lines.join("\n\n")}")
    end

    def validate_populated_elements_in_composition(elements_array, required: true)
      return false unless scratch_bundle.present?

      composition_resource = BundleDecorator.new(scratch_bundle.to_hash).composition_resource
      return false unless composition_resource.present?

      result = all_paths_are_populated?(composition_resource, elements_array)
      msg_type = if result
                   'info'
                 else
                   (required ? 'error' : 'warning')
                 end
      add_message(msg_type, populated_paths_info(composition_resource, elements_array))
      assert result, 'Some of the elements are not populated. See the list in messages tab.' if required
    end

    def validate_populated_slices_in_composition(slices_array)
      return false unless scratch_bundle.present?

      composition_resource = BundleDecorator.new(scratch_bundle.to_hash).composition_resource
      return false unless composition_resource.present?

      passed = slices_array.all? { |slice| process_one_slice_validation?(composition_resource, slice) }
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
      all_errors = section_codes_array.map do |code|
        process_one_section_validation(composition, code, elements_array, optional)
      end.compact
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

    def calculate_message_level(failed: false, warning: false, info: false)
      return 'error' if failed
      return 'warning' if warning
      return 'info' if info

      'info'
    end

    def subject_resource
      return false unless scratch_bundle.present?

      bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
      composition_resource = bundle_resource.composition_resource
      return false unless composition_resource.present?

      subject = composition_resource.subject
      return false unless subject.present?

      bundle_resource.resource_by_reference(subject.reference)
    end

    def resource_type(resource)
      return nil unless resource.present?

      resource.respond_to?(:resourceType) ? resource.resourceType : resource['resourceType']
    end

    def author_resource
      return nil unless scratch_bundle.present?

      bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
      composition = bundle_resource.composition_resource
      return nil unless composition.present?

      author_ref = composition_author_ref(composition)
      return nil unless author_ref.present?

      ref_str = author_ref.respond_to?(:reference) ? author_ref.reference : author_ref['reference']
      ref_str.present? ? bundle_resource.resource_by_reference(ref_str) : nil
    end

    def attester_party_resource
      return nil unless scratch_bundle.present?

      bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
      composition = bundle_resource.composition_resource
      return nil unless composition.present?

      attester_with_party = composition_attester_with_party(composition)
      return nil unless attester_with_party.present?

      ref_str = party_ref_str(attester_with_party)
      ref_str.present? ? bundle_resource.resource_by_reference(ref_str) : nil
    end

    def custodian_resource
      return nil unless scratch_bundle.present?

      bundle_resource = BundleDecorator.new(scratch_bundle.to_hash)
      composition = bundle_resource.composition_resource
      return nil unless composition.present?

      custodian_ref = composition_custodian_ref(composition)
      return nil unless custodian_ref.present?

      ref_str = custodian_ref.respond_to?(:reference) ? custodian_ref.reference : custodian_ref['reference']
      ref_str.present? ? bundle_resource.resource_by_reference(ref_str) : nil
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

    def composition_attester_metadata
      data = load_metadata_yaml
      return [] unless data.present?

      data['attester'] || data[:attester] || []
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
      sub_els = elements.filter { |el| metadata_subelement?(el) && !metadata_slice?(el) }
      return [] if sub_els.empty?

      build_parent_groups_from_subelements(sub_els)
    end

    # Returns author MS elements for the given resource type: complex elements only (no slices, no sub-elements).
    # Each element has :expression and :min; :expression has no "." and :id has no ":".
    def author_complex_ms_elements_for_type(author_metadata, resource_type)
      author_entry = author_entry_for_type(author_metadata, resource_type)
      return [] unless author_entry.present?

      elements = author_entry['elements'] || author_entry[:elements] || []
      elements.reject { |el| metadata_subelement?(el) || metadata_slice?(el) }
    end

    # Returns parent groups for author MS sub-elements: complex elements that have sub-elements (no slices).
    # Each group has :parent, :mandatory (array of expression strings), :optional (array).
    def author_ms_subelement_parent_groups(author_metadata, resource_type)
      author_entry = author_entry_for_type(author_metadata, resource_type)
      return [] unless author_entry.present?

      elements = author_entry['elements'] || author_entry[:elements] || []
      sub_els = elements.filter { |el| metadata_subelement?(el) }
      return [] if sub_els.empty?

      build_parent_groups_from_subelements(sub_els)
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

      header = "**Referenced author**: #{resource_type_str}#{" — #{profile_str}" if profile_str.present?}"
      parent_groups.each { |group| add_subelement_group_message(resource, group, header, use_error_level: true) }
      assert parent_groups_mandatory_result(resource, parent_groups),
             'When parent exists and any mandatory Must Support sub-element is missing. See the list in messages tab.'
    end

    def validate_custodian_ms_elements(resource, elements_config)
      return unless resource.present? && elements_config.present?

      mandatory, optional = elements_config_mandatory_optional_paths(elements_config)
      mandatory_ok = mandatory.all? { |path| resolve_path(resource, path).first.present? }
      optional_ok = optional.all? { |path| resolve_path(resource, path).first.present? }
      msg_type = if mandatory_ok
                   optional_ok ? 'info' : 'warning'
                 else
                   'error'
                 end
      header = referenced_resource_header(resource, 'custodian')
      add_message(msg_type, ms_elements_populated_message(header, resource, mandatory + optional))
      assert mandatory_ok, 'When mandatory Must Support element is missing (e.g. name). See the list in messages tab.'
    end

    def validate_custodian_ms_subelements(resource, parent_groups, resource_type_str, profile_str)
      return unless resource.present?

      header = "**Referenced custodian**: #{resource_type_str}#{" — #{profile_str}" if profile_str.present?}"
      parent_groups.each { |group| add_subelement_group_message(resource, group, header, use_error_level: false) }
    end

    def validate_custodian_ms_identifier_slices(resource, slices, resource_type_str, profile_str)
      return unless resource.present? && slices.present?

      slice_results = identifier_slice_results(resource, slices)
      header = "**Referenced custodian**: #{resource_type_str}#{" — #{profile_str}" if profile_str.present?}"
      msg_type = identifier_slices_message_type(slice_results, :all)
      add_message(msg_type,
                  "Must support identifier slices correctly populated\n\n#{header}\n\n## List of Must Support " \
                  "identifier slices populated or missing (type and system when populated)\n\n#{identifier_slice_lines_with_type(slice_results).join("\n\n")}")
    end

    def validate_attester_party_ms_elements(resource, elements_config)
      return unless resource.present? && elements_config.present?

      mandatory, optional = elements_config_mandatory_optional_paths(elements_config)
      mandatory_ok = mandatory.all? { |path| resolve_path(resource, path).first.present? }
      optional_ok = optional.all? { |path| resolve_path(resource, path).first.present? }
      msg_type = if mandatory_ok
                   optional_ok ? 'info' : 'warning'
                 else
                   'error'
                 end
      header = referenced_resource_header(resource, 'attester.party')
      add_message(msg_type, ms_elements_populated_message(header, resource, mandatory + optional))
      assert mandatory_ok, 'When any mandatory Must Support element is missing. See the list in messages tab.'
    end

    def validate_attester_party_ms_subelements(resource, parent_groups, resource_type_str, profile_str)
      return unless resource.present?

      header = "**Referenced attester.party**: #{resource_type_str}#{" — #{profile_str}" if profile_str.present?}"
      parent_groups.each { |group| add_subelement_group_message(resource, group, header, use_error_level: true) }
      assert parent_groups_mandatory_result(resource, parent_groups),
             'When parent exists and any mandatory Must Support sub-element is missing. See the list in messages tab.'
    end

    def validate_attester_party_ms_identifier_slices(resource, slices, resource_type_str, profile_str)
      return unless resource.present? && slices.present?

      slice_results = identifier_slice_results(resource, slices)
      header = "**Referenced attester.party**: #{resource_type_str}#{" — #{profile_str}" if profile_str.present?}"
      msg_type = identifier_slices_message_type(slice_results, :all)
      add_message(msg_type,
                  "Must support identifier slices correctly populated\n\n#{header}\n\n## List of Must Support " \
                  "identifier slices populated or missing (type and system when populated)\n\n#{identifier_slice_lines_with_type(slice_results).join("\n\n")}")
    end

    def validate_author_ms_elements(resource, author_config_elements)
      return unless resource.present? && author_config_elements.present?

      mandatory, optional = elements_config_mandatory_optional_paths(author_config_elements)
      mandatory_ok = mandatory.all? { |path| resolve_path(resource, path).first.present? }
      optional_ok = optional.all? { |path| resolve_path(resource, path).first.present? }
      msg_type = if mandatory_ok
                   optional_ok ? 'info' : 'warning'
                 else
                   'error'
                 end
      header = referenced_resource_header(resource, 'author')
      section_title = 'List of Must Support elements (complex) populated or missing'
      add_message(msg_type,
                  ms_elements_populated_message(header, resource, mandatory + optional, section_title: section_title))
      assert mandatory_ok, 'When any mandatory Must Support element is missing. See the list in messages tab.'
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

      identifier_type_display_from_coding(type_val)
    end

    def identifier_type_display_from_coding(type_val)
      if type_val.respond_to?(:coding) && type_val.coding.present?
        c = type_val.coding.first
        ", type: #{(c.respond_to?(:display) ? c.display : c['display']).presence || (c.respond_to?(:code) ? c.code : c['code']).presence || '—'}"
      elsif type_val.is_a?(Hash) && type_val['coding'].present?
        c = type_val['coding'].first
        ", type: #{c['display'].presence || c['code'].presence || '—'}"
      else
        ''
      end
    end

    def test_subject_ms_subelements_when_parent_populated
      resource = subject_resource
      skip_if resource.blank?, 'No subject (Patient) resource to validate for Must Support sub-elements'

      validate_populated_sub_elements_when_parent_populated(resource, PATIENT_MS_SUBELEMENT_GROUPS)
    end

    def test_subject_ms_identifier_slices
      resource = subject_resource
      skip_if resource.blank?, 'No subject (Patient) resource to validate for identifier slices'

      validate_ms_identifier_slices_in_resource(resource, PATIENT_MS_IDENTIFIER_SLICES)
    end

    def test_composition_author_ms_elements
      check_bundle_exists_in_scratch
      resource = author_resource
      skip_if resource.blank?, 'No author reference found on Composition'
      skip_if resource_type(resource) == 'Device',
              'Referenced author entry is type of Device; skip Must Support validation'
      author_meta = composition_author_metadata
      skip_if author_meta.blank?, 'No author metadata available'
      complex_elements = author_complex_ms_elements_for_type(author_meta, resource_type(resource))
      skip_if complex_elements.blank?,
              "No complex Must Support elements defined for author type #{resource_type(resource)}"
      validate_author_ms_elements(resource, complex_elements)
    end

    def test_composition_author_ms_subelements
      check_bundle_exists_in_scratch
      resource = author_resource
      skip_if resource.blank?, 'No author reference found on Composition'
      skip_if resource_type(resource) == 'Device', 'Referenced author resource type is Device'
      author_meta = composition_author_metadata
      skip_if author_meta.blank?, 'No author metadata available'
      parent_groups = author_ms_subelement_parent_groups(author_meta, resource_type(resource))
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

    def test_composition_attester_party_ms_elements
      check_bundle_exists_in_scratch
      resource = attester_party_resource
      skip_if resource.blank?, 'Attester or attester.party is not populated'

      attester_meta = composition_attester_metadata
      skip_if attester_meta.blank?, 'No attester metadata available'

      resource_type_str = resource_type(resource)
      elements_config = author_complex_ms_elements_for_type(attester_meta, resource_type_str)
      skip_if elements_config.blank?,
              "No complex Must Support elements defined for attester.party type #{resource_type_str}"

      validate_attester_party_ms_elements(resource, elements_config)
    end

    def test_composition_attester_party_ms_subelements
      check_bundle_exists_in_scratch
      resource = attester_party_resource
      skip_if resource.blank?, 'Attester or attester.party is not populated'
      attester_meta = composition_attester_metadata
      skip_if attester_meta.blank?, 'No attester metadata available'
      parent_groups = author_ms_subelement_parent_groups(attester_meta, resource_type(resource))
      skip_if parent_groups.blank?,
              'Referenced attester.party resource type has no complex elements with Must Support sub-elements'
      rtype_str, profile_str = author_resource_type_and_profiles(resource)
      validate_attester_party_ms_subelements(resource, parent_groups, rtype_str, profile_str)
    end

    def test_composition_attester_party_ms_identifier_slices
      check_bundle_exists_in_scratch
      resource = attester_party_resource
      skip_if resource.blank?, 'Attester or attester.party is not populated'

      resource_type_str = resource_type(resource)
      slices = AUTHOR_MS_IDENTIFIER_SLICES_BY_TYPE[resource_type_str] || []
      skip_if slices.blank?, 'Referenced attester.party resource type has no Must Support identifier slices'

      rtype_str, profile_str = author_resource_type_and_profiles(resource)
      validate_attester_party_ms_identifier_slices(resource, slices, rtype_str, profile_str)
    end

    def test_subject_ms_elements
      resource = subject_resource
      skip_if resource.blank?, 'No subject (Patient) resource to validate for Must Support elements'
      mandatory_primitives = %w[identifier name gender birthDate]
      optional_primitives = %w[telecom address communication generalPractitioner]
      optional_slices = %w[indigenousStatus genderIdentity individualPronouns]
      mandatory_ok = all_paths_are_populated?(resource, mandatory_primitives)
      optional_ok = subject_optional_ms_result(resource, optional_primitives, optional_slices)
      level = calculate_message_level(failed: !mandatory_ok, warning: mandatory_ok && !optional_ok,
                                      info: mandatory_ok && optional_ok)
      info_lines = populated_paths_info_raw(resource,
                                            mandatory_primitives + optional_primitives) + subject_optional_slice_messages(
                                              resource, optional_slices
                                            )
      add_message(level, info_lines.join("\n\n"))
      assert mandatory_ok,
             'Some of the mandatory Must Support elements are not populated. See the list in messages tab.'
    end

    def expected_profile_urls_for_section(section_data)
      section_data[:entries].flat_map do |e|
        (e[:profiles] || []).map { |p| p.to_s.include?('|') ? p.to_s.split('|').last : p }
      end.uniq
    end

    def process_one_section_read?(section_data, section, body, expected_profile_urls)
      if section.blank?
        add_message('error', "#{section_data[:short]} (#{section_data[:code]})\n\n#{body}")
        return true
      end
      section_read_add_message_for_populated?(section_data, section, body, expected_profile_urls)
    end

    def section_read_add_message_for_populated?(section_data, section, body, expected_profile_urls)
      refs = section.entry_references
      has_entries = refs.any?
      all_correct = refs_all_correct_profile?(refs, BundleDecorator.new(scratch_bundle.to_hash),
                                              expected_profile_urls)
      return add_section_read_error?(section_data, body) if has_entries && !all_correct
      return add_section_read_warning?(section_data, body) if section.empty_reason_str.present? && !has_entries
      return add_section_read_info?(section_data, body) if has_entries && all_correct

      add_section_read_error_no_entries?(section_data, body)
    end

    def refs_all_correct_profile?(refs, bundle_resource, expected_profile_urls)
      refs.all? do |ref|
        resource = bundle_resource.resource_by_reference(ref)
        next false unless resource.present?

        (resource.meta&.profile || []).any? { |prof| expected_profile_urls.include?(prof) }
      end
    end

    def add_section_read_error?(section_data, body)
      add_message('error', "#{section_data[:short]} (#{section_data[:code]})\n\n#{body}")
      true
    end

    def add_section_read_warning?(section_data, body)
      add_message('warning', "#{section_data[:short]} (#{section_data[:code]})\n\n#{body}")
      false
    end

    def add_section_read_info?(section_data, body)
      add_message('info', "#{section_data[:short]} (#{section_data[:code]})\n\n#{body}")
      false
    end

    def add_section_read_error_no_entries?(section_data, body)
      add_message('error',
                  "#{section_data[:short]} (#{section_data[:code]}) - section has no entries and no emptyReason\n\n#{body}")
      true
    end

    def section_empty_reason_text(section)
      return "emptyReason: #{section.empty_reason_str}" if section.empty_reason_str.present?

      'No entries; no emptyReason.'
    end

    def section_entry_lines(refs, bundle_resource)
      refs.map do |ref|
        resource = bundle_resource.resource_by_reference(ref)
        if resource.present?
          profiles = (resource.meta&.profile || []).join(', ')
          "**#{ref}**: #{resource.resourceType} (#{profiles})"
        else
          "**#{ref}**: (resource not found)"
        end
      end
    end

    def valid_resource_types_for_section(section_data)
      section_data[:entries].map { |entry| entry[:profiles] }.flatten
                            .map { |profile| profile.split('|').first }.uniq
    end

    def build_info_entry_section_lines(section_data, normalized_sections_data, valid_types)
      section_title = "### #{section_data[:short]} (#{section_data[:code]})"
      filtered = normalized_sections_data.find { |s| s['code'] == section_data[:code] }
      entity = SectionTestClass.new(filtered, scratch_bundle)
      ref_lines = (entity.references || []).filter_map { |ref| info_entry_line_for_ref(entity, ref, valid_types) }
      [section_title, *ref_lines]
    end

    def info_entry_line_for_ref(section_test_entity, ref, valid_types)
      resource = section_test_entity.get_resource_by_reference(ref)
      return nil unless resource.present?

      can_present = valid_types.include?(resource.resourceType)
      profiles = (resource.meta&.profile || []).join(', ')
      " #{boolean_to_existent_string(can_present)} **#{ref}**: #{resource.resourceType} (#{profiles})"
    end

    def section_ms_elements_result(section_config, section_resource)
      title = "### #{section_config[:short]}(#{section_config[:code]})"
      result = [title]
      section_config[:ms_elements].each do |element|
        populated = resolve_path(section_resource, element[:expression]).first.present?
        result << "**#{element[:expression]}**: #{boolean_to_existent_string(populated)}"
      end
      result
    end

    def composition_sub_elements_mandatory_result(grouped, mandatory_ms, composition_resource)
      grouped.all? do |parent_path, sub_elements|
        next true unless resolve_path(composition_resource, parent_path).first.present?

        (mandatory_ms & sub_elements).all? { |el| resolve_path(composition_resource, el).first.present? }
      end
    end

    def composition_run_sub_group_messages(composition_resource, grouped, mandatory_ms)
      grouped.each do |parent_path, sub_els|
        add_message_for_composition_sub_group(composition_resource, parent_path, sub_els, mandatory_ms)
      end
    end

    def add_message_for_composition_sub_group(composition_resource, parent_path, sub_elements, mandatory_ms)
      unless resolve_path(composition_resource, parent_path).first.present?
        add_message('warning', composition_sub_group_unpopulated_msg(parent_path, sub_elements))
        return
      end
      level = composition_sub_group_message_level(composition_resource, sub_elements, mandatory_ms)
      add_message(level, populated_paths_info(composition_resource, sub_elements))
    end

    def composition_sub_group_unpopulated_msg(parent_path, sub_elements)
      "Must Support sub-elements correctly populated\n\nComposition\n\n**Complex element #{parent_path}** " \
        "is not populated. Must Support sub-elements that would be validated: #{sub_elements.join(', ')}."
    end

    def composition_sub_group_message_level(composition_resource, sub_elements, mandatory_ms)
      types = sub_elements.map do |sub_el|
        present = resolve_path(composition_resource, sub_el).first.present?
        if mandatory_ms.include?(sub_el)
          present ? 'info' : 'error'
        else
          (present ? 'info' : 'warning')
        end
      end.uniq
      if types.include?('error')
        'error'
      else
        (types.include?('warning') ? 'warning' : 'info')
      end
    end

    def sub_elements_message_type(resource, sub_els, mandatory)
      types = sub_els.map do |el|
        if resolve_path(resource, el).first.present?
          'info'
        else
          (mandatory.include?(el) ? 'error' : 'warning')
        end
      end.uniq
      if types.include?('error')
        'error'
      else
        (types.include?('warning') ? 'warning' : 'info')
      end
    end

    def process_parent_groups_sub_element_messages(resource, parent_groups)
      any = false
      parent_groups.each do |group|
        next unless resolve_path(resource, group[:parent]).first.present?

        any = true
        sub_els = (group[:mandatory] || []) + (group[:optional] || [])
        add_message(sub_elements_message_type(resource, sub_els, group[:mandatory] || []),
                    populated_paths_info(resource, sub_els))
      end
      any
    end

    def parent_groups_mandatory_result(resource, parent_groups)
      parent_groups.all? do |group|
        next true unless resolve_path(resource, group[:parent]).first.present?

        (group[:mandatory] || []).all? { |el| resolve_path(resource, el).first.present? }
      end
    end

    def identifier_slice_results(resource, slices)
      identifiers = identifiers_from_resource(resource) || []
      slices.map { |slice| { slice: slice, identifier: find_identifier_by_system(identifiers, slice[:system]) } }
    end

    def identifier_slices_message_type(slice_results, kind)
      populated = slice_results.map { |r| r[:identifier].present? }
      all_ok = populated.all?
      any_ok = populated.any?
      if kind == :all ? all_ok : any_ok
        'info'
      else
        'warning'
      end
    end

    def identifier_slice_lines_with_type(slice_results)
      slice_results.map do |r|
        if r[:identifier].present?
          type_str = identifier_type_display(r[:identifier])
          "✅ Populated: **#{r[:slice][:name]}** — system: #{r[:slice][:system]}#{type_str}"
        else
          "❌ Missing: **#{r[:slice][:name]}**"
        end
      end
    end

    def identifier_slice_lines_simple(slice_results)
      slice_results.map do |r|
        if r[:identifier].present?
          "✅ Populated: **#{r[:slice][:name]}** — system: #{r[:slice][:system]}"
        else
          "❌ Missing: **#{r[:slice][:name]}**"
        end
      end
    end

    def process_one_slice_validation?(composition_resource, slice)
      required_paths = slice[:mandatory_ms_sub_elements].map { |el| "#{slice[:path]}.#{el}" }
      optional_paths = slice[:optional_ms_sub_elements].map { |el| "#{slice[:path]}.#{el}" }
      all_paths = required_paths + optional_paths
      required_ok = all_paths_are_populated?(composition_resource, required_paths)
      return slice_validation_add_error?(all_paths, composition_resource) unless required_ok

      slice_validation_add_optional_message?(composition_resource, all_paths, optional_paths)
    end

    def slice_validation_add_error?(all_paths, composition_resource)
      msg = "#{populated_paths_info(composition_resource, all_paths)}\n\nSlice: **event:careProvisioningEvent**"
      add_message('error', msg)
      false
    end

    def slice_validation_add_optional_message?(composition_resource, all_paths, optional_paths)
      optional_ok = all_paths_are_populated?(composition_resource, optional_paths)
      event = composition_resource.event_by_code('PCPR')
      full_msg = "#{populated_paths_info(composition_resource, all_paths)}\n\nSlice: **event:careProvisioningEvent**"
      add_message(optional_ok && event.present? ? 'info' : 'warning',
                  optional_ok ? full_msg : populated_paths_info(composition_resource, all_paths))
      true
    end

    def process_one_section_validation(composition, section_code, elements_array, optional)
      section = composition.section_by_code(section_code)
      if section.blank?
        add_message(optional ? 'warning' : 'error', "#{get_section_name(section_code)} is missing")
        return optional ? nil : true
      end
      section_validation_add_message(section, elements_array)
    end

    def section_validation_add_message(section, elements_array)
      body = section_ms_elements_message(section, elements_array)
      all_populated = all_paths_are_populated?(section, elements_array)
      if all_populated
        add_message('info', "Section correctly populated\n\n#{body}")
        nil
      else
        add_message('error',
                    "For section with any mandatory Must Support element in section missing (i.e. title, code, text)\n\n#{body}")
        true
      end
    end

    def composition_author_ref(composition)
      composition.respond_to?(:author) && composition.author.present? ? composition.author.first : nil
    end

    def composition_attester_with_party(composition)
      attesters = composition.respond_to?(:attester) ? composition.attester : nil
      return nil if attesters.blank?

      attesters.find { |a| (a.respond_to?(:party) ? a.party : a['party']).present? }
    end

    def party_ref_str(attester_with_party)
      party_ref = attester_with_party.respond_to?(:party) ? attester_with_party.party : attester_with_party['party']
      party_ref.respond_to?(:reference) ? party_ref.reference : party_ref['reference']
    end

    def composition_custodian_ref(composition)
      composition.respond_to?(:custodian) && composition.custodian.present? ? composition.custodian : nil
    end

    def metadata_subelement?(element)
      (element['expression'] || element[:expression]).to_s.include?('.')
    end

    def metadata_slice?(element)
      (element['id'] || element[:id]).to_s.include?(':')
    end

    def author_entry_for_type(author_metadata, resource_type)
      author_metadata.find do |entry|
        (entry['resource_type'] || entry[:resource_type]).to_s == resource_type.to_s
      end
    end

    def build_parent_groups_from_subelements(sub_els)
      grouped = sub_els.group_by { |el| (el['expression'] || el[:expression]).to_s.split('.').first }
      grouped.map do |parent, els|
        mandatory_els = els.select { |e| ((e['min'] || e[:min]) || 0).positive? }
        optional_els = els.reject { |e| ((e['min'] || e[:min]) || 0).positive? }
        { parent: parent, mandatory: mandatory_els.map { |e| e['expression'] || e[:expression] },
          optional: optional_els.map { |e| e['expression'] || e[:expression] } }
      end
    end

    def add_subelement_group_message(resource, group, header, use_error_level: true)
      parent_path = group[:parent]
      sub_els = (group[:mandatory] || []) + (group[:optional] || [])
      unless resolve_path(resource, parent_path).first.present?
        add_subelement_group_unpopulated_message(header, parent_path, sub_els)
        return
      end
      level = subelement_group_message_level(resource, group, sub_els, use_error_level)
      add_message(level, subelement_group_populated_message(header, parent_path, resource, sub_els))
    end

    def add_subelement_group_unpopulated_message(header, parent_path, sub_els)
      add_message('warning', "#{header}\n\n**Complex element #{parent_path}** is not populated. " \
                             "Must Support sub-elements that would be validated: #{sub_els.join(', ')}.")
    end

    def subelement_group_message_level(resource, group, sub_els, use_error_level)
      return sub_elements_message_type(resource, sub_els, group[:mandatory] || []) if use_error_level

      sub_els.all? { |expr| resolve_path(resource, expr).first.present? } ? 'info' : 'warning'
    end

    def subelement_group_populated_message(header, parent_path, resource, sub_els)
      list_body = sub_els.map do |expr|
        "#{boolean_to_existent_string(resolve_path(resource, expr).first.present?)}: **#{expr}**"
      end.join("\n\n")
      "Must Support sub-elements correctly populated\n\n#{header}\n\n## Complex element **#{parent_path}** — " \
        "Must Support sub-elements populated or missing\n\n#{list_body}"
    end

    def elements_config_mandatory_optional_paths(elements_config)
      mandatory_els = elements_config.select { |el| ((el['min'] || el[:min]) || 0).positive? }
      optional_els = elements_config.reject { |el| ((el['min'] || el[:min]) || 0).positive? }
      [mandatory_els.map { |el| el['expression'] || el[:expression] }, optional_els.map do |el|
        el['expression'] || el[:expression]
      end]
    end

    def referenced_resource_header(resource, label)
      rtype = resource.respond_to?(:resourceType) ? resource.resourceType : resource['resourceType']
      profiles = resource_profiles(resource)
      profile_str = profiles.is_a?(Array) ? profiles.join(', ') : profiles.to_s
      "**Referenced #{label}**: #{rtype}#{" — #{profile_str}" if profile_str.present?}"
    end

    def ms_elements_populated_message(header, resource, expressions,
                                      section_title: 'List of Must Support elements populated or missing')
      lines = expressions.map do |expr|
        "#{boolean_to_existent_string(resolve_path(resource, expr).first.present?)}: **#{expr}**"
      end
      "Must Support elements correctly populated\n\n#{header}\n\n## #{section_title}\n\n#{lines.join("\n\n")}"
    end

    def subject_optional_ms_result(resource, optional_primitives, optional_slices)
      primitives_ok = all_paths_are_populated?(resource, optional_primitives)
      slices_ok = optional_slices.all? do |slice|
        url = SUBJECT_OPTIONAL_SLICE_URLS[slice]
        url && get_extension_value_by_url(resource, url).present?
      end
      primitives_ok && slices_ok
    end

    def subject_optional_slice_messages(resource, optional_slices)
      optional_slices.map do |slice|
        url = SUBJECT_OPTIONAL_SLICE_URLS[slice]
        result = url && get_extension_value_by_url(resource, url).present?
        "#{boolean_to_existent_string(result)}: **#{slice}**"
      end
    end
  end
end
