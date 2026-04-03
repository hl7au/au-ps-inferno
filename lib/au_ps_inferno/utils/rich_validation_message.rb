# frozen_string_literal: true

# A class to represent a rich validation message for the better and informative output
class RichValidationMessage
  def initialize(rich_messages)
    @rich_messages = rich_messages
    first = rich_messages.first
    @title = calculate_title(first)
    @indexes = uniq_attribute_values(rich_messages, :idx)
    @entry_references = uniq_attribute_values(rich_messages, :ref)
    @resource_ids = uniq_attribute_values(rich_messages, :resource_id)
    @message = first.message
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
    value_blank = value.blank?
    return nil if title.blank? && value_blank
    return nil if value_blank

    title.present? ? "**#{title}**: #{value}" : value
  end

  def calculate_title(message)
    profile = message.profile
    resource_type = message.resource_type
    profile.present? ? "### #{resource_type} (#{profile})" : "### #{resource_type}"
  end
end
