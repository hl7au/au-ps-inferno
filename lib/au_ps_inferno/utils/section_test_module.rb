# frozen_string_literal: true

require_relative 'section_test_class'
require_relative 'messages_keeper_class'

# A base class for all tests that validate sections of the AU PS Bundle
module SectionTestModule
  def validate_section_resources(section_name)
    assert scratch_bundle.present?, 'Bundle resource not found'
    section_test_entity = SectionTestClass.new(Constants::SECTIONS_NAMES_MAPPING[section_name], scratch_bundle)
    assert section_test_entity.data.present?, 'Section data not found'
    assert section_test_entity.references.present?, 'Section entity references not found'

    validate_all_section_references(section_test_entity)
  end

  private

  def validate_all_section_references(section_test_entity)
    messages_keeper = MessagesKeeper.new
    section_test_entity.references.each_with_index do |ref, idx|
      validate_section_reference(ref, idx, section_test_entity, messages_keeper)
    end
    report_validation_results(messages_keeper)
  end

  def could_be_validated?(requirements, resource)
    return true if requirements.empty?

    requirements.map do |req|
      if req['value'].instance_of?(Array)
        req['value'].include?(find_a_value_at(resource, req['path']))
      else
        find_a_value_at(resource, req['path']) == req['value']
      end
    end.all?
  end

  def validate_section_reference(ref, idx, section_test_entity, messages_keeper)
    resource = section_test_entity.get_resource_by_reference(ref)
    assert resource.present?, "Resource not found for reference #{ref}"
    resource_is_expected?(section_test_entity, resource)

    conditional_validation(resource, idx, section_test_entity, messages_keeper)
  end

  def conditional_validation(resource, idx, section_test_entity, messages_keeper)
    if section_test_entity.target_resources_hash.keys.empty?
      get_validation_messages(resource: resource, idx: idx, messages_keeper: messages_keeper)
    else
      validate_with_resource_hash(resource, idx, section_test_entity, messages_keeper)
    end
  end

  def resource_is_expected?(section_test_entity, resource)
    assert section_test_entity.resource_type_is_expected?(resource.resourceType),
           "Resource #{resource.resourceType} is not expected for section #{section_test_entity.humanized_name}"
  end

  def parse_resource_type_key(resource_type_key)
    parts = resource_type_key.to_s.split('|')
    {
      resource_type: parts.first,
      profile_url: parts.length == 2 ? parts.last : nil
    }
  end

  def validate_with_resource_hash(resource, idx, section_test_entity, messages_keeper)
    section_test_entity.target_resources_hash.each_key do |resource_type_key|
      parsed_key = parse_resource_type_key(resource_type_key)
      next unless resource.resourceType == parsed_key[:resource_type]

      next unless could_be_validated?(section_test_entity.find_requirements(resource_type_key), resource)

      get_validation_messages(resource: resource, profile_url: parsed_key[:profile_url], idx: idx,
                              messages_keeper: messages_keeper)
      break unless section_test_entity.is_multiprofile
    end
  end

  def get_validation_messages(resource:, idx:, messages_keeper:, profile_url: nil)
    initial_message_count = messages.length

    resource_is_valid?(resource: resource, profile_url: profile_url)

    new_messages = messages.length > initial_message_count ? messages[initial_message_count..] : []
    messages.slice!(initial_message_count..-1) if messages.length > initial_message_count

    new_messages.each do |msg|
      messages_keeper.add_message(MessagesKeeper.build_rich_message_hash(resource, idx, profile_url, msg))
    end
  end

  def formatted_output_messages(messages_array)
    uniq_attribute_values(messages_array, :signature).map do |signature|
      filtered_messages = filtered_messages_by_signature(messages_array, signature)
      idx = uniq_attribute_values(filtered_messages, :idx).join(', ')
      ids = uniq_attribute_values(filtered_messages, :resource_id).join(', ')
      [calculate_title(filtered_messages.first), idx.present? ? "**IDx:** #{idx}" : nil,
       ids.present? ? "**IDs:** #{ids}" : nil, filtered_messages.first[:message]].compact.join("\n\n")
    end.join("\n\n")
  end

  def calculate_title(message)
    profile = message[:profile]
    resource_type = message[:resource_type]
    profile.present? ? "### #{resource_type} (#{profile})" : "### #{resource_type}"
  end

  def filtered_messages_by_signature(messages_array, signature)
    messages_array.select do |message|
      message[:signature] == signature
    end
  end

  def uniq_attribute_values(messages_array, attribute)
    messages_array.map { |message| message[attribute] }.uniq.sort
  end

  def report_validation_results(messages_keeper)
    add_message('error', formatted_output_messages(messages_keeper.errors)) if messages_keeper.errors.any?
    warning formatted_output_messages(messages_keeper.warnings) if messages_keeper.warnings.any?
    assert messages_keeper.errors.empty?, 'Some resources are not valid according to the section requirements'
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
