# frozen_string_literal: true

require 'digest'

# A class to keep messages for a section test
class MessagesKeeper
  class << self
    def build_rich_message_hash(resource, idx, profile_url, message)
      # NOTE: I don't like this method, because we need to pass arguments that are not related to the message itself.
      # But it's easier to use than to pass a block to the add_message method. So, let's keep it for now.
      # Pavel Rozhkov, 2026-01-18
      build_hash(resource, idx, profile_url, message)
    end

    private

    def build_hash(resource, idx, profile_url, message)
      message_body = cleanup_message_body(message[:message], resource.resourceType, resource.id)
      {
        message: message_body,
        type: message[:type],
        resource_type: resource.resourceType,
        profile: profile_url,
        resource_id: resource.id,
        idx: idx,
        signature: Digest::MD5.hexdigest([resource.resourceType, profile_url, message_body].compact.join('|'))
      }
    end

    def cleanup_message_body(message, resource_type, resource_id)
      # This function is used to remove resourceType/id from the message body.
      # AllergyIntolerance: AllergyIntolerance.code: None of the ...
      # AllergyIntolerance/123: AllergyIntolerance.code: None of the ...
      # should be converted to:
      # AllergyIntolerance.code: None of the ...
      string_to_replace = resource_id.present? ? "#{resource_type}/#{resource_id}: " : "#{resource_type}: "
      message.sub(string_to_replace, '')
    end
  end

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

  private

  def messages_of_type(msg_type)
    @messages.filter do |message|
      message[:type] == msg_type
    end
  end
end
