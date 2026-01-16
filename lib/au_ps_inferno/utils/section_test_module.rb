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

    validation_messages = validate_all_section_references(
      section_references, bundle_resource_decorator, target_resources_hash,
      target_resource_types, is_multiprofile, target_section
    )

    report_validation_results(filter_error_messages(validation_messages), filter_warning_messages(validation_messages))
  end

  private

  def messages_by_type(validation_messages, msg_type)
    validation_messages.filter do |validation_message|
      validation_message[:type] == msg_type
    end
  end

  def filter_error_messages(validation_messages)
    messages_by_type(validation_messages, 'error')
  end

  def filter_warning_messages(validation_messages)
    messages_by_type(validation_messages, 'warning')
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
    section_references.map.with_index do |ref, idx|
      validate_section_reference(ref, idx, bundle_resource, target_resources_hash, target_resource_types,
                                 is_multiprofile, target_section).then do |errors, warnings|
        [errors, warnings]
      end
    end.flatten
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
      messages_array = validate_without_runnable_messages(resource, nil)
      if messages_array.any?
        errors.concat(collect_messages_and_keep(messages_array, 'error', resource, idx, nil))
        warnings.concat(collect_messages_and_keep(messages_array, 'warning', resource, idx, nil))
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
          messages_array = validate_without_runnable_messages(resource, profile_url)
          next unless messages_array.any?

          errors.concat(collect_messages_and_keep(messages_array, 'error', resource, idx, profile_url))
          warnings.concat(collect_messages_and_keep(messages_array, 'warning', resource, idx, profile_url))
        end
        break unless is_multiprofile
      end
    end
    [errors, warnings]
  end

  def build_message_hash(resource, idx, profile_url, message)
    id = resource.id ? "#{resource.resourceType}/#{resource.id}[#{idx}]" : "#{resource.resourceType}[#{idx}]"
    { id: id, message: message[:message], type: message[:type], profile: profile_url }
  end

  def collect_messages_and_keep(messages_array, type, resource, idx, profile_url)
    collect_messages(messages_array, type).map { |message| build_message_hash(resource, idx, profile_url, message) }
  end

  def validate_without_runnable_messages(resource, profile_url)
    custom_resource_is_valid?(resource: resource, profile_url: profile_url)
  end

  def custom_resource_is_valid?(resource:, profile_url: nil)
    initial_message_count = messages.length

    resource_is_valid?(resource: resource, profile_url: profile_url)

    all_messages = messages
    new_messages = if all_messages.length > initial_message_count
                     all_messages[initial_message_count..]
                   else
                     []
                   end

    messages.slice!(initial_message_count..-1) if messages.is_a?(Array) && messages.length > initial_message_count

    new_messages.map do |msg|
      {
        type: msg[:type] || msg['type'] || 'error',
        message: msg[:message] || msg['message'] || msg.to_s
      }
    end
  end

  def collect_messages(messages_array, type)
    messages_array.select { |message| message[:type] == type }
  end

  def formatted_output_messages(messages_array)
    messages_ids = messages_array.map { |message| message[:id] }.uniq.sort
    messages_ids.map do |message_id|
      filtered_messages = messages_array.select do |message|
        message[:id] == message_id
      end
      filtered_messages = filtered_messages.map { |message| message[:message] }.uniq
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
