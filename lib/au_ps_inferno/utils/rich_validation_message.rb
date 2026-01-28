# frozen_string_literal: true

# A class to represent a rich validation message for the better and informative output
class RichValidationMessage
  def initialize(rich_messages)
    @rich_messages = rich_messages
    @title = calculate_title(rich_messages.first)
    @indexes = uniq_attribute_values(rich_messages, :idx)
    @entry_references = uniq_attribute_values(rich_messages, :ref)
    @resource_ids = uniq_attribute_values(rich_messages, :resource_id)
    @message = rich_messages.first.message
  end

  def to_s
    [
      [nil, @title],
      ['Indexes', @indexes.join(', ')],
      ['Entry References', @entry_references.join(', ')],
      ['Resource IDs', @resource_ids.join(', ')],
      [nil, @message]
    ].map { |part| msg_line(title: part[0], value: part[1]) }.compact.join("\n\n")
  end

  private

  def uniq_attribute_values(messages_array, attribute)
    messages_array.map { |message| message.send(attribute) }.uniq.sort
  end

  def msg_line(title: nil, value: nil)
    return nil if title.blank? && value.blank?
    return nil if value.blank?

    title.present? ? "**#{title}**: #{value}" : value
  end

  def calculate_title(message)
    profile = message.profile
    resource_type = message.resource_type
    profile.present? ? "### #{resource_type} (#{profile})" : "### #{resource_type}"
  end
end
