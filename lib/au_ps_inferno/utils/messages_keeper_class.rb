# frozen_string_literal: true

require 'digest'

# A class to keep messages for a section test
class MessagesKeeper
  attr_reader :messages

  def initialize
    @messages = []
  end

  def add_message(message)
    @messages << message
  end

  def errors
    messages_of_type('error')
  end

  def warnings
    messages_of_type('warning')
  end

  def self.build_rich_message_hash(resource, idx, profile_url, message)
    # NOTE: I don't like this method, because we need to pass arguments that are not related to the message itself.
    # But it's easier to use than to pass a block to the add_message method. So, let's keep it for now.
    # Pavel Rozhkov, 2026-01-18
    resource_type = resource.resourceType
    {
      message: message[:message],
      type: message[:type],
      resource_type: resource_type,
      profile: profile_url,
      resource_id: resource.id,
      idx: idx,
      signature: Digest::MD5.hexdigest([resource_type, profile_url, message[:message]].compact.join('|'))
    }
  end

  private

  def messages_of_type(msg_type)
    @messages.filter do |message|
      message[:type] == msg_type
    end
  end
end
