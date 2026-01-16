# frozen_string_literal: true

# A base class for all tests that validate sections of the AU PS Bundle
module SectionTestModule
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

  def validate_section_reference(ref, idx, bundle_resource, target_resources_hash, target_resource_types,
                                 is_multiprofile, target_section)
    errors = []
    warnings = []
    resource = bundle_resource.resource_by_reference(ref)
    assert resource.present?, "Resource not found for reference #{ref}"
    assert target_resource_types.uniq.include?(resource.resourceType),
           "Resource #{resource.resourceType} is not expected for section #{target_section.code_display_str}"

    if target_resources_hash.keys.empty?
      validation_response = validate_without_runnable_messages(resource, nil)
      messages_array = validation_response[:message_hashes]
      if messages_array.any?
        collect_messages_and_keep(messages_array, 'error', errors, resource, idx, nil)
        collect_messages_and_keep(messages_array, 'warning', warnings, resource, idx, nil)
      end
    else
      target_resources_hash.each_key do |resource_type_key|
        resource_is_okay = true
        resource_type_info = target_resources_hash[resource_type_key]
        resource_type_key_splitted = resource_type_key.to_s.split('|')
        resource_type = resource_type_key_splitted.first
        resource&.id
        next unless resource.resourceType == resource_type

        requirements = resource_type_info.keys.include?('requirements') ? resource_type_info['requirements'] : []
        if requirements.any?
          resource_is_okay = requirements.map do |req|
            find_a_value_at(resource, req['path']) == req['value']
          end.all?
        end

        if resource_is_okay
          profile_url = resource_type_key_splitted.last if resource_type_key_splitted.length == 2
          validation_response = validate_without_runnable_messages(resource, profile_url)
          info validation_response.to_s
          next unless validation_response[:message_hashes].any?

          collect_messages_and_keep(validation_response[:message_hashes], 'error', errors, resource, idx, profile_url)
          collect_messages_and_keep(validation_response[:message_hashes], 'warning', warnings, resource, idx,
                                    profile_url)
        end
        break unless is_multiprofile
      end
    end
    [errors, warnings]
  end

  def build_message_hash(resource, idx, profile_url, message)
    { id: resource.id ? "#{resource.resourceType}/#{resource.id}[#{idx}]" : "#{resource.resourceType}[#{idx}]",
      message: message[:message], profile: profile_url }
  end

  def collect_messages_and_keep(messages_array, type, target_array, resource, idx, profile_url)
    filtered_messages = collect_messages(messages_array, type)
    filtered_messages.map { |message| build_message_hash(resource, idx, profile_url, message) }
    target_array.concat(filtered_messages)
  end

  def validate_without_runnable_messages(resource, profile_url)
    resource_is_valid?(resource: resource, profile_url: profile_url, add_messages_to_runnable: false)
  end

  def collect_messages(messages_array, type)
    messages_array.select { |message| message[:type] == type }
  end

  def formatted_output_messages(messages_array)
    messages_ids = messages_array.map { |message| message[:id] }.uniq.sort
    messages_ids.map do |message_id|
      filtered_messages = messages_array.select do |message|
        message[:id] == message_id
      end.map { |message| message[:message] }.uniq
      "## #{message_id}:\n\n #{filtered_messages.map { |message| message }.join('\n\n')}"
    end.join("\n\n")
  end

  def report_validation_results(section_errors, section_warnings)
    add_message('error', "# Errors:\n\n #{formatted_output_messages(section_errors)}") if section_errors.any?
    warning "# Warnings:\n\n #{formatted_output_messages(section_warnings)}" if section_warnings.any?
    assert section_errors.none?, 'Some resources are not valid according to the section requirements'
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
end
