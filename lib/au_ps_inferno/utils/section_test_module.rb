# frozen_string_literal: true

require_relative 'section_test_class'
require_relative 'messages_keeper_class'
require_relative 'rich_message_class'
require_relative 'rich_validation_message'

# A base class for all tests that validate sections of the AU PS Bundle
module SectionTestModule
  def validate_section_resources(section_name)
    skip_if scratch_bundle.blank?, 'Bundle resource not found'
    section_test_entity = SectionTestClass.new(Constants::SECTIONS_NAMES_MAPPING[section_name], scratch_bundle)
    skip_if section_test_entity.data.blank?, 'Section data not found'
    skip_if section_test_entity.references.blank?, 'Section entity references not found'

    validate_all_section_references(section_test_entity)
  end

  def entry_resources_info
    group_section_output(resolve_path(scratch_bundle, 'entry.resource').map do |resource|
      resource_type = resolve_path(resource, 'resourceType').first
      profiles = resolve_path(resource, 'meta.profile').sort
      profiles.empty? ? resource_type : "#{resource_type} (#{profiles.join(', ')})"
    end).join("\n\n")
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

    conditional_validation(ref, resource, idx, section_test_entity, messages_keeper)
  end

  def conditional_validation(ref, resource, idx, section_test_entity, messages_keeper)
    if section_test_entity.target_resources_hash.keys.empty?
      get_validation_messages(ref, resource: resource, idx: idx, messages_keeper: messages_keeper)
    else
      validate_with_resource_hash(ref, resource, idx, section_test_entity, messages_keeper)
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

  def validate_with_resource_hash(ref, resource, idx, section_test_entity, messages_keeper)
    section_test_entity.target_resources_hash.each_key do |resource_type_key|
      parsed_key = parse_resource_type_key(resource_type_key)
      next unless resource.resourceType == parsed_key[:resource_type]

      next unless could_be_validated?(section_test_entity.find_requirements(resource_type_key), resource)

      get_validation_messages(ref: ref, resource: resource, profile_url: parsed_key[:profile_url], idx: idx,
                              messages_keeper: messages_keeper)
      break unless section_test_entity.is_multiprofile
    end
  end

  def get_validation_messages(ref:, resource:, idx:, messages_keeper:, profile_url: nil)
    initial_message_count = messages.length

    resource_is_valid?(resource: resource, profile_url: profile_url)

    new_messages = messages.length > initial_message_count ? messages[initial_message_count..] : []
    messages.slice!(initial_message_count..-1) if messages.length > initial_message_count

    new_messages.each do |msg|
      messages_keeper.add_message(RichMessage.new(resource, msg, profile_url, idx, ref))
    end
  end

  def formatted_output_messages(messages_array)
    messages_array.map(&:signature).uniq.sort.map do |signature|
      RichValidationMessage.new(MessagesKeeper.filtered_messages_by_signature(messages_array, signature))
    end
  end

  def report_validation_results(messages_keeper)
    formatted_output_messages(messages_keeper.errors).each do |rich_validation_message|
      add_message('error', rich_validation_message.to_s)
    end
    formatted_output_messages(messages_keeper.warnings).each do |rich_validation_message|
      add_message('warning', rich_validation_message.to_s)
    end
    assert messages_keeper.errors.empty?, 'Some resources are not valid according to the section requirements'
  end
end
